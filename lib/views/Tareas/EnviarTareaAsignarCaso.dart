import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/AWS.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/SendTask.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';

class AsignarCaso extends StatefulWidget {

  AsignarCaso({this.myUserRes,this.pathAudioRes,this.listaCasosRes,this.isTextoRes,this.tareaRes,this.blocTaskSend,this.blocTaskReceived});
  final String pathAudioRes;
  final Usuario myUserRes;
  final List<Caso> listaCasosRes;
  final bool isTextoRes;
  final Tarea tareaRes;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;

  @override
  _AsignarCasoState createState() => _AsignarCasoState();
}

class _AsignarCasoState extends State<AsignarCaso> {

  double alto = 0;
  double ancho = 0;
  Usuario myUser;
  AudioPlayer audioPlayer;
  AudioCache audioCache;
  StreamSubscription _durationSubscription;
  Duration _duration;
  String pathAudio = '';
  List<Caso> listaCasos;
  bool isTexto = false;

  Tarea tareaCreada;
  Caso casoSeleccionado;
  TextEditingController controlleBuscador;
  TextEditingController controlleExplicacion;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tareaCreada = widget.tareaRes;

    isTexto = widget.isTextoRes;

    controlleBuscador = new TextEditingController();
    controlleExplicacion = new TextEditingController();

    myUser = widget.myUserRes;
    pathAudio = widget.pathAudioRes;
    listaCasos = widget.listaCasosRes;

    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);

    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
      print('$_duration');
    });

  }

  void dispose() {
    audioPlayer.stop();
    _durationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
          width: ancho,
          child: Text('Enviar tarea',
            style: estiloLetras(22,Colors.grey),textAlign: TextAlign.right,),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey,size: 35,),
          onPressed: () {
            Map<String,bool> result = new Map<String,bool>();
            result['enviado'] = false;
            result['sonido'] = sonido;
            Navigator.of(context).pop(result);
          },
        ),
      ),
      body: _contenido(),
    );
  }

  Widget _contenido(){
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: alto * 0.14,
              child: _header(),
            ),
            Container(
              height: alto * 0.06,
              child: _buscadorCasos(),
            ),
            Container(
              child: _Listadocasos(),
            ),
            SizedBox(height: alto * 0.02,child: Container(color: Colors.white,),),
            isTexto ? Container() :
            Container(
              width: ancho,
              child: _opcAvanz(),
            ),
            isTexto ? SizedBox(height: alto * 0.02) : SizedBox(height: alto * 0.05,),
            isTexto ? _enviarText() :
            Container(
              height: alto * 0.16,
              child: enviandoTareaAudio ?
              Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorButtonBlueAT,)),
              )
                  :
              grabador(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(){

    Image imagenAvatar = Image.network(avatarImage);
    if(myUser != null && myUser.avatar != ''){
      try{
        imagenAvatar = Image.network('$directorioImage${myUser.avatar}');
      }catch(e){
        print('No cargo imagen');
      }
    }

    return Container(
      padding: EdgeInsets.only(left: ancho * 0.05,right: ancho * 0.05),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: CircleAvatar(
              radius: ancho * 0.1,
              backgroundImage: imagenAvatar.image,
            ),
          ),
          Expanded(
            flex: 7,
            child: Text('${myUser.name}',textAlign: TextAlign.center,
              style: estiloLetras(alto * 0.03,colortitulo,negrita: FontWeight.bold),),
          )
        ],
      ),
    );
  }

  bool iconBuscadorCasos = false;
  Widget _buscadorCasos(){
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text('Caso',textAlign: TextAlign.right,
                style: estiloLetras(alto * 0.028,colortitulo)),
          ),
          Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.only(left: ancho * 0.03,right: ancho * 0.08),
                height: alto * 0.05,
                child: TextField(
                  controller: controlleBuscador,
                  style:estiloLetras(alto * 0.025,colortitulo),
                  onChanged: (value){
                    //controlleBuscador.text = value;
                    if(value.length > 0){
                      iconBuscadorCasos = true;
                    }else{
                      iconBuscadorCasos = false;
                    }
                    setState(() {});
                  },
                  decoration: new InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 0.6),
                        borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                      ),
                      suffixIcon: IconButton(
                        icon: iconBuscadorCasos ? Icon(Icons.clear) : Icon(Icons.search),
                        onPressed: (){
                          if(iconBuscadorCasos){
                            iconBuscadorCasos = false;
                            WidgetsBinding.instance.addPostFrameCallback((_) => controlleBuscador.clear());
                            setState(() {});
                          }
                        },
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 0.6),
                        borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                      ),
                      border: new OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 0.6),
                        borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:EdgeInsets.symmetric(horizontal: ancho * 0.05, vertical: alto * 0.01)
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  Map<int,bool> mapcasoSelect = Map();
  Widget _Listadocasos(){

    bool seleccionado = false;
    if((mapcasoSelect[0] != null && mapcasoSelect[0])){
      seleccionado = true;
    }

    return Container(
      padding: EdgeInsets.only(left: ancho * 0.08,right: ancho * 0.08),
      child: Column(
        children: <Widget>[
          InkWell(
            child: Container(
              height: alto * 0.05,
              width: ancho,
              color:   seleccionado ? colorfondoSelectUser : Colors.white,
              child: Center(
                child: Container(
                  width: ancho,
                  child: Text('No asignar a ninguno',textAlign: TextAlign.left,
                    style: estiloLetras(19,colortitulo,negrita: seleccionado ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              ),
            ),
            onTap: (){
              Caso caso = Caso(id: 0);
              if(mapcasoSelect[caso.id] == null){mapcasoSelect[caso.id] = false;}

              mapcasoSelect.forEach((key,value){
                if(key == caso.id){
                  mapcasoSelect[caso.id] = !mapcasoSelect[caso.id];
                  if(mapcasoSelect[caso.id]){casoSeleccionado = caso;}else{casoSeleccionado = null;}
                }else{
                  mapcasoSelect[key] = false;
                }
              });
              setState(() {});
            },
          ),
          SizedBox(height: alto * 0.01,),
          Container(
            height: isTexto ? alto * 0.45 : alto * 0.33,
            child: listaCasos == null ? Container() : ListView.builder(
              itemCount: listaCasos.length,
              itemBuilder: (context,index){

                Caso caso = listaCasos[index];
                if(controlleBuscador.text.length != 0 && !caso.name.toLowerCase().contains(controlleBuscador.text.toLowerCase())){
                  return Container();
                }

                bool userSelect = false;
                if(mapcasoSelect[caso.id] != null && mapcasoSelect[caso.id]){
                  userSelect = true;
                }
                return Container(

                  margin: EdgeInsets.only(bottom: alto * 0.02),
                  color: userSelect ? colorfondoSelectUser : Colors.white,
                  child: InkWell(
                    onTap: (){
                      if(mapcasoSelect[caso.id] == null){mapcasoSelect[caso.id] = false;}

                      mapcasoSelect.forEach((key,value){
                        if(key == caso.id){
                          mapcasoSelect[caso.id] = !mapcasoSelect[caso.id];
                          if(mapcasoSelect[caso.id]){casoSeleccionado = caso;}else{casoSeleccionado = null;}
                        }else{
                          mapcasoSelect[key] = false;
                        }
                      });
                      setState(() {});
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${caso.name}',style: estiloLetras(19,colortitulo,negrita: userSelect ? FontWeight.bold : FontWeight.normal),),
                        //SizedBox(height: alto * 0.008,),
                        Text('${caso.nameCompany}',style: estiloLetras(12,colortitulo),)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool cargandoEnviarTareaTexto = false;
  Widget _enviarText(){
    return Container(
      height: alto * 0.08,
      margin: EdgeInsets.only(left: ancho * 0.25,right: ancho * 0.25),
      width: ancho,
      child: cargandoEnviarTareaTexto ?

      Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorButtonBlueAT,)),
      )
          :

      InkWell(
        child: Container(
          width: ancho,
          height: alto * 0.045,
          decoration: new BoxDecoration(
            border: Border.all(width: 1,color: colorBordeOpc),
            color: colorButtonBlueAT,
            borderRadius: BorderRadius.all(Radius.circular(10),),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Enviar ",
                  style: estiloLetras(alto * 0.04,Colors.white)),
              Container(
                height: alto * 0.04,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset('assets/image/SendTask2.png',color: Colors.white,),
                ),
              )
            ],
          ),
        ),
        onTap: () async {

          cargandoEnviarTareaTexto = true;
          setState(() {});

          bool entre = false;
          int keySelect = 0;
          mapcasoSelect.forEach((key,value){
            if(value){
              entre = true;
              keySelect = key;
            }
          });

          if(entre){
            if(keySelect != 0){
              tareaCreada.project_id = keySelect;
            }
            bool res = await sendTask(tareaCreada);
            if(res){
              await updateData.actualizarListaRecibidos(widget.blocTaskReceived);
              await updateData.actualizarListaEnviados(widget.blocTaskSend);
              Map<String,bool> result = new Map<String,bool>();
              result['enviado'] = true;
              Navigator.of(context).pop(result);
            }else{
              showAlert('NO SE ENVIO',Colors.red[400]);
            }
          }else{
            showAlert('SELECCIONAR AL MENOS UN(1) CASO',Colors.red[400]);
          }
          cargandoEnviarTareaTexto = false;
          setState(() {});
        },
      ),
    );
  }

  bool opcionesOpen = false;
  DateTime fechaTask;
  String _pathAdjunto = '';
  String _fileNameAdjunto = '';
  Widget _opcAvanz(){
    return Container(
      margin: EdgeInsets.only(left: ancho * 0.08,right: ancho * 0.08),
      width: ancho,
      decoration: new BoxDecoration(
        border: Border.all(width: 1,color: colorBordeOpc),
        borderRadius: BorderRadius.all(Radius.circular(10),),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: alto * 0.05,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: EdgeInsets.only(top: opcionesOpen ? alto * 0 : 0.05,right: ancho * 0.02),
                    child: Text('Más opciones',textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: alto * 0.024,
                      color: colortitulo,
                      letterSpacing: 0.5,
                    ))
                  )
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      margin: EdgeInsets.only(top: opcionesOpen ? alto * 0.01 : 0,right: ancho * 0.04,left: ancho * 0.03),
                      child: opcionesOpen ?
                      Image.asset('assets/image/tri1.png',width: alto * 0.01,) :
                      Image.asset('assets/image/tri2.png',height: alto * 0.05,),
                    ),
                    onTap: (){
                      opcionesOpen = !opcionesOpen;
                      setState(() {});
                    },
                  ),
                )
              ],
            ),
          ),
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01,left: ancho * 0.05),
            child: Text('Explicación adicional',textAlign: TextAlign.left,
                style: estiloLetras(alto * 0.024,colortitulo)),
          ),
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01,left: ancho * 0.05,right: ancho * 0.05),
            child: TextField(
              controller: controlleExplicacion,
              maxLines: 5,
              style:estiloLetras(alto * 0.025,colortitulo),
              decoration: new InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 0.6),
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 0.6),
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                  ),
                  border: new OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 0.6),
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:EdgeInsets.symmetric(horizontal: ancho * 0.05, vertical: alto * 0.01)
              ),
            ),
          ),
          !opcionesOpen ? Container() : SizedBox(height: alto * 0.02,),
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01,left: ancho * 0.05,right: ancho * 0.05),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: ancho * 0.03),
                    child: Text('Fecha',textAlign: TextAlign.right,
                        style: estiloLetras(alto * 0.024,colortitulo)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      height: alto * 0.045,
                      decoration: new BoxDecoration(
                        border: Border.all(width: 1,color: colorBordeOpc),
                        borderRadius: BorderRadius.all(Radius.circular(10),),
                      ),
                      child: fechaTask != null ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('${fechaTask.day}-${fechaTask.month}-${fechaTask.year}',
                              style: estiloLetras(alto * 0.024,colortitulo)),
                          InkWell(
                            child: Icon(Icons.clear),
                            onTap: (){
                              setState(() {
                                fechaTask = null;
                              });
                            },
                          ),
                        ],
                      )
                          : Container(),
                    ),
                    onTap: (){
                      // DatePicker.showDatePicker(context,
                      //     showTitleActions: true,
                      //     minTime: DateTime(2018, 1, 1),
                      //     maxTime: DateTime(2100, 12, 31),
                      //     onChanged: (date) {
                      //       setState(() {
                      //         fechaTask = date;
                      //       });
                      //     }, onConfirm: (date) {
                      //       setState(() {
                      //         fechaTask = date;
                      //       });
                      //     }, currentTime: fechaTask != null ? fechaTask : DateTime.now(),
                      //     locale: LocaleType.es
                      // );
                    },
                  ),
                )
              ],
            ),
          ),
          !opcionesOpen ? Container() : SizedBox(height: alto * 0.02,),
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01,left: ancho * 0.05,right: ancho * 0.05),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: ancho * 0.03),
                    child: Text('Adjuntos',textAlign: TextAlign.right,
                        style: estiloLetras(alto * 0.024,colortitulo)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      height: alto * 0.045,
                      decoration: new BoxDecoration(
                        border: Border.all(width: 1,color: colorBordeOpc),
                        borderRadius: BorderRadius.all(Radius.circular(10),),
                      ),
                      child: Center(
                        child: Text(_fileNameAdjunto.length > 10 ? '${_fileNameAdjunto.substring(0,10)}...' : '$_fileNameAdjunto',
                            style: estiloLetras(alto * 0.022,colortitulo)),
                      ),
                    ),
                    onTap: () async {
                      try{
                        _pathAdjunto = await FilePicker.getFilePath(type: FileType.ANY, fileExtension: '');
                        if(_pathAdjunto != null){
                          _fileNameAdjunto = _pathAdjunto.split('/').last;
                          setState(() {});
                        }
                      }catch(e){
                        print(e.toString());
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          !opcionesOpen ? Container() : SizedBox(height: alto * 0.02,),
        ],
      ),
    );
  }



  Widget grabador(){
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            width: ancho * 0.12,
            height: alto * 0.18,
            margin: EdgeInsets.only(left: ancho * 0.05),
            child: botonPlay(),
          ),
          Container(
            width: ancho * 0.12,
            height: alto * 0.18,
            margin: EdgeInsets.only(left: ancho * 0.05),
            child: botonBorrar(),
          ),
          Container(
            width: ancho* 0.15,
            height: alto * 0.18,
            margin: EdgeInsets.only(left: ancho * 0.1),
            child: Center(child: Text('$minutos:$segundos',
              style: estiloLetras(alto * 0.026,Colors.grey[600]),textAlign: TextAlign.left,)),
          ),
          Container(
            width: ancho * 0.28,
            height: alto * 0.14,
            margin: EdgeInsets.only(left: ancho * 0.08),
            child: botonEnviar(),
          ),
        ],
      ),
    );
  }

  UpdateData updateData = new UpdateData();
  bool enviandoTareaAudio = false;
  botonEnviar(){
    return GestureDetector(
        onTap: () async {

          enviandoTareaAudio = true;
          setState(() {});

          Map<String,bool> mapVery = new Map<String,bool>();
          mapVery['caso'] = false;
          mapcasoSelect.forEach((key,value){
            if(value){
              mapVery['caso'] = true;
              tareaCreada.project_id = key;
            }
          });

          mapVery['audio'] = false;
          if(tareaCreada.url_audio != ''){
            mapVery['audio'] = true;
          }

          if(controlleExplicacion.text != ''){
            tareaCreada.description = controlleExplicacion.text;
          }

          if(fechaTask != null){
            String fechadead = '${fechaTask.year}-${fechaTask.month}-${fechaTask.day}';
            tareaCreada.deadline = fechadead;
          }

          if(_pathAdjunto != null){
            Map<String,String> mapArchivo = await subirArchivo(_pathAdjunto,_fileNameAdjunto);
            if(mapArchivo['subir'] == 'true'){
              tareaCreada.url_attachment = mapArchivo['location'];
            }
          }

          if(mapVery['caso'] && mapVery['audio']){

            bool res = await sendTask(tareaCreada);
            if(res){
              await updateData.actualizarListaRecibidos(widget.blocTaskReceived);
              await updateData.actualizarListaEnviados(widget.blocTaskSend);
              Map<String,bool> result = new Map<String,bool>();
              result['enviado'] = true;
              result['sonido'] = false;
              Navigator.of(context).pop(result);
            }else{
              showAlert('NO SE ENVIO',Colors.red[400]);
            }
          }else{
            if(!mapVery['caso']){
              showAlert('SELECCIONAR AL MENOS UN(1) CASO',Colors.red[400]);
            }else{
              if(!mapVery['audio']){
                showAlert('DEBE HABER UN AUDIO',Colors.red[400]);
              }
            }
            enviandoTareaAudio = false;
            setState(() {});
          }
        },
        child: Container(
          child: FittedBox(
              fit: BoxFit.fill,
              child: Image.asset('assets/image/SendTask.png'),
          ),
        )
    );
  }
  //*******************************************************
  //*******************************************************
  //*******************************************************
  //******************REPRODUCIR***************************
  //*******************************************************
  //*******************************************************
  //*******************************************************


  bool reproduciendo = false;
  botonPlay(){
    Image imagen;

    if(sonido){
      if(reproduciendo){
        imagen = Image.asset('assets/image/Pausa.png',width: ancho * 0.3,);
      }else{
        imagen = Image.asset('assets/image/playOpa.png',width: ancho * 0.3,);
      }
    }else{
      imagen = Image.asset('assets/image/playOff.png',width: ancho * 0.3,);
    }

    return InkWell(
      child: Container(
        child: imagen,
      ),
      onTap: (){
        if(sonido){
          if(!reproduciendo){
            audioPlayer.play('$pathAudio',isLocal: true,);
          }else{
            audioPlayer.stop();
          }
          setState(() {
            reproduciendo = !reproduciendo;
          });
        }
      },
    );
  }
  botonBorrar(){

    Image imagen;

    if(sonido){
      imagen = Image.asset('assets/image/deleteOpa.png',width: ancho * 0.3,);
    }else{
      imagen = Image.asset('assets/image/deleteOff.png',width: ancho * 0.3,);
    }

    return InkWell(
      child: Container(
        child: imagen,
      ),
      onTap: (){
        tareaCreada.url_audio = '';
        setState(() {
          borrar = true;
          sonido = false;
          reproduciendo = false;
          minutos = '00';
          segundos = '00';
          mostrarMinutosEspera = 0;
          segundoEspera = 0;
        });
      },
    );
  }
  int mostrarMinutosEspera = 0;
  int segundoEspera = 0;
  String minutos = '00';
  String segundos = '00';
  bool escuchando = false;
  bool borrar = false;
  bool sonido = true;
  Future ConteoMinutos() async {
    if(escuchando){
      segundoEspera++;
      if(segundoEspera > 59){
        mostrarMinutosEspera++;
      }

      minutos = mostrarMinutosEspera.toString();
      segundos = segundoEspera.toString();

      if(mostrarMinutosEspera < 10){
        minutos = '0$minutos';
      }
      if(segundoEspera < 10){
        segundos = '0$segundos';
      }
      setState((){});
      await Future.delayed(Duration(seconds: 1));
      ConteoMinutos();
    }
  }
}
