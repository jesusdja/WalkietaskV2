import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/upload_background_documents.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/textfield_constraints.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class NewTaskForUser extends StatefulWidget {

  final Usuario user;
  final bool isPersonal;
  final String pathAudio;
  final List<Caso> listaCasos;
  final BlocProgress blocIndicatorProgress;
  final Map mapMinSeg;

  NewTaskForUser({
    @required this.user,
    @required this.isPersonal,
    @required this.pathAudio,
    @required this.listaCasos,
    @required this.blocIndicatorProgress,
    @required this.mapMinSeg,
  });

  @override
  _NewTaskForUserState createState() => _NewTaskForUserState();
}

class _NewTaskForUserState extends State<NewTaskForUser> {

  double alto = 0;
  double ancho = 0;

  int mostrarMinutosEspera = 0;
  int segundoEspera = 0;
  int mostrarMinutosEsperaOld = 0;
  int segundoEsperaOld = 0;

  bool isPersonal = false;
  bool isAudio = false;
  bool opcionesOpen = false;
  bool iconBuscadorCasos = false;
  bool enviandoTarea = false;
  bool reproduciendo = false;
  bool pause = false;
  bool pausado = false;
  bool loadGuests = false;

  String audioPath;
  String titleTask = '';
  String descriptionTask = '';
  String _pathAdjunto;
  String _fileNameAdjunto = '';
  String minutos = '00';
  String segundos = '00';
  String minutosold = '00';
  String segundosold = '00';

  DateTime fechaTask;

  TextStyle textStylePrimary;
  TextStyle textStylePrimaryBold;
  TextStyle textStyleBlueLitle;
  TextStyle textStyleGreenLitle;
  TextStyle textStyleRedLitle;
  TextStyle textStyleLitle;

  Usuario user;
  Caso casoSeleccionado;

  TextEditingController controlleBuscadorCasos = TextEditingController();

  Map<int,bool> mapcasoSelect = {};
  List<Caso> listaCasos;
  List<int> projectAccepted = [];

  AudioPlayer audioPlayer = new AudioPlayer();
  Duration _durationPause = Duration(seconds: 0);

  conexionHttp connectionHttp = new conexionHttp();

  ScrollController controller = ScrollController();

  TextEditingController controllerTitle = TextEditingController();

  @override
  void initState() {
    super.initState();

    user = widget.user;
    isPersonal = widget.isPersonal;
    audioPath = widget.pathAudio;
    isAudio = audioPath.isNotEmpty;
    listaCasos = widget.listaCasos;

    mostrarMinutosEspera =  0;
    segundoEspera =  0;
    minutos =  '00';
    segundos =  '00';

    mostrarMinutosEsperaOld = widget.mapMinSeg['mostrarMinutosEspera'] ?? 0;
    segundoEsperaOld = widget.mapMinSeg['segundoEspera'] ?? 0;
    minutosold = widget.mapMinSeg['minutos'] ?? '00';
    segundosold = widget.mapMinSeg['segundos'] ?? '00';

    listenerAudio();
    _getGuests();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer?.dispose();
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022, color: WalkieTaskColors.black, spacing: 1);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.022, color: WalkieTaskColors.black, spacing: 0.5);
    textStyleBlueLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.primary, spacing: 0.5, fontWeight: FontWeight.bold);
    textStyleGreenLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.color_89BD7D, spacing: 0.5, fontWeight: FontWeight.bold);
    textStyleRedLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.color_E07676, spacing: 0.5, fontWeight: FontWeight.bold);
    textStyleLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.black, spacing: 0.5, fontWeight: FontWeight.bold);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: WalkieTaskColors.white,
        appBar: _appBar(),
        bottomNavigationBar: _bottomNavigationBar(),
        body: _body(),
      ),
    );
  }

  Widget _body(){

    Image avatarUser = Image.network(avatarImage);
    if(user.avatar.isNotEmpty){
      avatarUser = Image.network(user.avatar);
    }

    return opcionesOpen ? _taskSendOpen() : _taskSendOut(avatarUser);
  }

  Widget _taskSendOut(Image avatarUser){
    return SingleChildScrollView(
      child: Container(
        width: ancho,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          children: [
            SizedBox(height: alto * 0.1,),
            Container(
              child: Text('Enviarás una tarea a ${user.name}', style: textStylePrimary,),
            ),
            Container(
              margin: EdgeInsets.only(top: alto * 0.01),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      decoration: new BoxDecoration(
                        color: bordeCirculeAvatar, // border color
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: alto * 0.08,
                        backgroundImage: avatarUser.image,
                        //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: alto * 0.02,right: ancho * 0.05,bottom: alto * 0.01),
              width: ancho * 0.85,
              child: Text('Titulo',textAlign: TextAlign.left,
                  style: textStylePrimary),
            ),
            _tituloTarea(),
            Container(
              margin: EdgeInsets.only(left: ancho * 0.05,right: ancho * 0.05),
              width: ancho,
              child: _opcAvanz(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskSendOpen(){
    List<Widget> widgets = [];

    widgets.add(SizedBox(height: alto * 0.01,));
    widgets.add(
        Container(
          margin: EdgeInsets.only(top: alto * 0.02,right: ancho * 0.05,bottom: alto * 0.01),
          width: ancho,
          child: Text('Titulo',textAlign: TextAlign.left,
              style: textStylePrimary),
        )
    );
    widgets.add(_tituloTarea());
    widgets.add(Container(
          width: ancho,
          margin: EdgeInsets.only(top: alto * 0.02,right: ancho * 0.05,bottom: alto * 0.01),
          child: Text('Descripción adicional',textAlign: TextAlign.left,
              style: textStylePrimary),
        ));
    widgets.add(Container(
          width: ancho,
          margin: EdgeInsets.only(top: alto * 0.01),
          child: TextFildGeneric(
            textInputType: TextInputType.multiline,
            padding: EdgeInsets.all(5.0),
            onChanged: (text) {
              setState(() {
                descriptionTask = text;
              });
              //blocIndicatorProgress.inList.add({'progressIndicator' : double.parse(text), 'viewIndicatorProgress' : true});
            },
            labelStyle: textStylePrimary,
            sizeH: alto,
            sizeW: ancho,
            borderColor: WalkieTaskColors.color_E2E2E2,
            sizeBorder: 1.2,
            textAlign: TextAlign.left,
            sizeHeight: alto * 0.2,
            maxLines: 8,
            //textInputAction: TextInputAction.done,
          ),
        ));
    widgets.add(Container(
      width: ancho,
      margin: EdgeInsets.only(top: alto * 0.01),
      child: _buscadorCasos(),
    ));
    widgets.add(Container(
      width: ancho,
      margin: EdgeInsets.only(top: alto * 0.01),
      child: _listadocasos(),
    ));
    widgets.add(SizedBox(height: alto * 0.02,));
    widgets.add(Container(
      width: ancho,
      margin: EdgeInsets.only(top: alto * 0.01,left: ancho * 0.05,right: ancho * 0.05),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(right: ancho * 0.03),
              child: Text('Fecha',textAlign: TextAlign.right,
                  style: textStylePrimary),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                DateTime newDateTime = await showDatePicker(
                    context: context,
                    initialDate: new DateTime.now(),
                    firstDate: new DateTime(2018),
                    lastDate: new DateTime(2025),
                    locale: Locale('es', 'ES')
                );
                if (newDateTime != null) {
                  Duration dif = newDateTime.difference(DateTime.now());
                  if(dif.inDays >= 0){
                    setState(() => fechaTask = newDateTime);
                  }else{
                    showAlert('Fecha debe ser mayor o igual a hoy.',Colors.red[400]);
                  }
                }
              },
              child: Container(
                height: alto * 0.045,
                decoration: new BoxDecoration(
                  border: Border.all(width: 1.2,color: colorBordeOpc),
                  borderRadius: BorderRadius.all(Radius.circular(5.0),),
                ),
                child: fechaTask != null ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('${fechaTask.day}-${fechaTask.month}-${fechaTask.year}',
                        style: textStylePrimary),
                    InkWell(
                      child: Icon(Icons.clear),
                      onTap: (){
                        setState(() {
                          fechaTask = null;
                        });
                      },
                    ),
                  ],
                ) : Container(),
              ),
            ),
          )
        ],
      ),
    ));
    widgets.add(SizedBox(height: alto * 0.02,));
    widgets.add(Container(
      width: ancho,
      margin: EdgeInsets.only(top: alto * 0.01,left: ancho * 0.05,right: ancho * 0.05),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(right: ancho * 0.03),
              child: Text('Adjuntos',textAlign: TextAlign.right,
                  style: textStylePrimary),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              child: Container(
                height: alto * 0.045,
                decoration: new BoxDecoration(
                  border: Border.all(width: 1.2,color: colorBordeOpc),
                  borderRadius: BorderRadius.all(Radius.circular(5.0),),
                ),
                child:_pathAdjunto != null ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(_fileNameAdjunto.length > 10 ? '${_fileNameAdjunto.substring(0,10)}...' : '$_fileNameAdjunto',
                        style: estiloLetras(alto * 0.022,colortitulo)),
                    InkWell(
                      child: Icon(Icons.clear),
                      onTap: (){
                        setState(() {
                          _pathAdjunto = null;
                        });
                      },
                    ),
                  ],
                ) : Container(),
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
    ));
    widgets.add(SizedBox(height: alto * 0.02,));

    return Container(
      width: ancho,
      padding: EdgeInsets.only(right: ancho * 0.05,left: ancho * 0.05),
      child: ListView(
        controller: controller,
        children: widgets,
      ),
    );
  }

  Widget _tituloTarea(){
    return Container(
      child: TextFieldConstraints(
        minHeight: alto * 0.04,
        maxHeight: alto * 0.15,
        sizeHeight: alto * 0.03,
        maxLines: null,
        autofocus: true,
        textEditingController: controllerTitle,
        initialValue: null,
        onChanged: (text) {
          setState(() {
            titleTask = text;
          });
        },
        labelStyle: textStylePrimary,
        sizeH: alto,
        sizeW: ancho,
        borderColor: WalkieTaskColors.color_E2E2E2,
        sizeBorder: 1.8,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buscadorCasos(){
    return Container(
      child: Row(
        children: <Widget>[
          Text('Asignar a proyecto:',textAlign: TextAlign.right,
              style: textStylePrimary),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: ancho * 0.03),
              height: alto * 0.04,
              child: TextFildGeneric(
                onChanged: (text) {
                  iconBuscadorCasos = text.length > 0;
                  setState(() {});
                },
                labelStyle: textStylePrimary,
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_E2E2E2,
                sizeBorder: 1.2,
                sizeHeight: alto * 0.045,
                textAlign: TextAlign.left,
                suffixIcon: InkWell(
                  child: iconBuscadorCasos ? Icon(Icons.clear) : Icon(Icons.search),
                  onTap: () async {
                    if(iconBuscadorCasos){
                      iconBuscadorCasos = false;
                      WidgetsBinding.instance.addPostFrameCallback((_){
                        controlleBuscadorCasos.clear();
                        setState(() {});
                      });
                      setState(() {});
                    }
                  },
                ),
                textEditingController: controlleBuscadorCasos,
                initialValue: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  FixedExtentScrollController fixedExtentScrollController =
  new FixedExtentScrollController();

  Widget _listadocasos(){
    bool seleccionado = false;
    if((mapcasoSelect[0] != null && mapcasoSelect[0])){
      seleccionado = true;
    }
    List<Widget> list = [InkWell(
      child: Container(
        height: alto * 0.05,
        width: ancho,
        color:   seleccionado ? colorfondoSelectUser : Colors.white,
        child: Center(
          child: Container(
            width: ancho,
            child: Text('No asignar a ninguno',textAlign: TextAlign.left,
              style: seleccionado ? textStylePrimaryBold : textStylePrimary,
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
    ),SizedBox(height: alto * 0.01,)];
    listaCasos.forEach((element) {
      list.add(widgetCase(element));
    });


    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
      height: alto * 0.25,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        border: new Border.all(
          width: 1.2,
          color: WalkieTaskColors.color_E2E2E2,
        ),
      ),
      child: NotificationListener<OverscrollNotification>(
        onNotification: (OverscrollNotification value) {
          if (value.overscroll < 0 && controller.offset + value.overscroll <= 0) {
            if (controller.offset != 0) controller.jumpTo(0);
            return true;
          }
          if (controller.offset + value.overscroll >= controller.position.maxScrollExtent) {
            if (controller.offset != controller.position.maxScrollExtent) controller.jumpTo(controller.position.maxScrollExtent);
            return true;
          }
          controller.jumpTo(controller.offset + value.overscroll);
          return true;
        },
        child: ListView(
          children: loadGuests ?
          [Container(
            width: ancho,
            padding: EdgeInsets.all(alto * 0.02),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )] : list,
        ),
      ),
    );
  }

  Widget widgetCase( Caso caso){
    if(controlleBuscadorCasos.text.length != 0 && !caso.name.toLowerCase().contains(controlleBuscadorCasos.text.toLowerCase())){
      return Container();
    }

    bool isAccepted = false;
    projectAccepted.forEach((element) { if(element == caso.id){ isAccepted = true;}});
    if(!isAccepted){ return Container();}

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
        child: Container(
          margin: EdgeInsets.only(top: alto * 0.005, bottom: alto * 0.01),
          child: Text('${caso.name}',style: userSelect ? textStylePrimaryBold : textStylePrimary),
        ),
      ),
    );
  }

  Widget _opcAvanz(){
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: alto * 0.05,
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: opcionesOpen ? alto * 0 : 0.05,right: ancho * 0.02),
                      child: Text('Más opciones',textAlign: TextAlign.right,style: textStylePrimary,),
                    )
                ),
                InkWell(
                  child: Container(
                    child: !opcionesOpen ?
                    Container(
                      width: ancho * 0.08,
                      height: alto * 0.08,
                      child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,
                        color: Colors.grey,),
                    ) :
                    Container(
                      width: ancho * 0.08,
                      height: alto * 0.08,
                      child: Image.asset('assets/image/icon_open_option.png',fit: BoxFit.fill,
                        color: Colors.grey,),
                    ),
                  ),
                  onTap: (){
                    opcionesOpen = !opcionesOpen;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(){

    Image avatarUser = Image.network(avatarImage);
    if(user.avatar.isNotEmpty){
      avatarUser = Image.network(user.avatar);
    }

    return AppBar(
      backgroundColor: Colors.grey[100],
      titleSpacing: 0,
      elevation: 0.0,
      title: Container(
        child: Row(
          children: [
            opcionesOpen ? Container(
              margin: EdgeInsets.only(right: ancho * 0.015),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      decoration: new BoxDecoration(
                        color: bordeCirculeAvatar, // border color
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: alto * 0.02,
                        backgroundImage: avatarUser.image,
                        //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                      ),
                    ),
                  ),
                ],
              ),
            ) : Container(),
            Text(opcionesOpen ? '${user.name} ${user.surname}' : 'Todo listo para enviar tarea', style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.025, color: WalkieTaskColors.black, spacing: 0.5, ),)
          ],
        ),
      ),
      leading: InkWell(
        onTap: () {
          if(opcionesOpen){
            setState(() {
              opcionesOpen = false;
            });
          }else{
            Navigator.of(context).pop(false);
          }
        },
        child: Container(
          child: Icon(Icons.arrow_back_ios, size: alto * 0.035, color: WalkieTaskColors.primary,),
        ),
      ),
    );
  }

  Widget _bottomNavigationBar(){
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01, left: ancho * 0.02, right: ancho * 0.04),
      width: ancho,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: isAudio ? _playSonund() : Container(height: 20,),
          ),
          InkWell(
            onTap: () => _sendTask(),
            child: Container(
              width: ancho * 0.2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  mostrarImage('SendTask'),
                  Text('Enviar', style: textStyleBlueLitle,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playSonund(){
    return Container(
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              if(!reproduciendo){
                print('botonPlay : $audioPath');
                audioPlayer.play(audioPath,isLocal: true,position: _durationPause);
              }else{
                await audioPlayer.pause();
              }
              setState(() {
                reproduciendo = !reproduciendo;
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: ancho * 0.03),
              width: ancho * 0.2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  pause ? mostrarImage('Pausa') : mostrarImage('playOpa'),
                  pause ? Text('Pausa',style: textStyleLitle,) : Text('Reproducir',style: textStyleGreenLitle,),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              margin: EdgeInsets.only(left: ancho * 0.01),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  mostrarImage('deleteOpa'),
                  Text('Eliminar',style: textStyleRedLitle,)
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: ancho * 0.05),
            child: reproduciendo ?
            Text('$minutos:$segundos', style: textStylePrimary,) :
                pausado ? Text('$minutos:$segundos', style: textStylePrimary,) :
                          Text('$minutosold:$segundosold', style: textStylePrimary,),
          ),
        ],
      ),
    );
  }

  Future<void> listenerAudio() async {
    audioPlayer.onAudioPositionChanged.listen((Duration  p){
      print('Current position: $p');
      _durationPause = p;
    });
    AudioPlayerState oldState = AudioPlayerState.COMPLETED;
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      print('Current player state: $s');
      if(AudioPlayerState.COMPLETED == s){
        setState(() {
          pause = false;
          reproduciendo = false;
          pausado = false;
          _durationPause = Duration(seconds: 0);
        });
      }
      if(AudioPlayerState.PAUSED == s){
        pause = false;
        pausado = true;
        setState(() {});
      }
      if(AudioPlayerState.PLAYING == s){
        if(oldState == AudioPlayerState.COMPLETED){
          _resetSoundPause();
        }
        pause = true;
        pausado = false;
        setState(() {});
        _contMinutePause();
      }
      oldState = s;

      if(AudioPlayerState.STOPPED == s){
        oldState = AudioPlayerState.COMPLETED;
      }
    });
  }

  Future<void> _contMinutePause() async {
    if(reproduciendo){
      await Future.delayed(Duration(seconds: 1));
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
      if(mounted){
        setState((){});
      }
      _contMinutePause();
    }
  }

  void _resetSoundPause(){
    minutos = '00';
    segundos = '00';
    mostrarMinutosEspera = 0;
    segundoEspera = 0;
    setState(() {});
  }

  Widget mostrarImage(String name){
    return Container(
      height: alto * 0.05,
      width: alto * 0.05,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ViewImage().assetsImage("assets/image/$name.png",).image,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  void _sendTask() async {

    if(audioPlayer.state == AudioPlayerState.PLAYING || audioPlayer.state == AudioPlayerState.PAUSED){
      audioPlayer.stop();
      setState(() {
        pause = false;
        reproduciendo = false;
        pausado = false;
        _durationPause = Duration(seconds: 0);
      });
    }

    enviandoTarea = true;
    setState(() {});
    try{
      if(!isAudio && titleTask.isEmpty){
        showAlert('Las tareas de texto deben llevar título.',WalkieTaskColors.color_E07676);
      }else{
        //VERIFICAR SI SE SELECCIONO UN INTEGRANTE
        int userSend = user.id;
        if(userSend != null){
          //VERIFICAR DATOS EXTRAS
          List<dynamic> listShared2 = await SharedPrefe().getValue('WalListDocument');
          listShared2 = listShared2 ?? [];
          List<String> listShared = [];
          listShared = listShared2.map((e) => e.toString()).toList();
          String shared = '';
          //id integrante | titulo | path audio | id caso | descripcion | fecha | path adjunto
          shared = '$userSend|';
          if(titleTask != null && titleTask.isNotEmpty){
            shared = '$shared$titleTask|';
          }else{ shared = '$shared|';}
          if(audioPath != null && isAudio){
            shared = '$shared$audioPath|';
          }else{ shared = '$shared|';}
          mapcasoSelect.forEach((key, value) {
            if(value){
              shared = '$shared$key|';
            }
          });
          if(mapcasoSelect.length == 0){ shared = '$shared|';}
          if(descriptionTask != null && descriptionTask.isNotEmpty){
            shared = '$shared$descriptionTask|';
          }else{ shared = '$shared|';}
          if(fechaTask != null){
            shared = '$shared$fechaTask|';
          }else{ shared = '$shared|';}
          if(_pathAdjunto != null && _pathAdjunto.isNotEmpty){
            shared = '$shared$_pathAdjunto|';
          }else{ shared = '$shared|';}
          listShared.add(shared);
          bool errorAudio = true;
          if(isAudio){
            bool exit = audioPath != null ? await File(audioPath).exists() : false;
            print('EL AUDIO = $exit');
            if(!exit){
              errorAudio = false;
              showAlert('Problemas para cargar el audio. Intente de nuevo.',WalkieTaskColors.color_E07676);
            }
          }
          if(errorAudio){
            //ENVIAR A SEGUNDO PLANO
            await SharedPrefe().setStringListValue('WalListDocument',listShared);
            uploadBackDocuments(widget.blocIndicatorProgress);
            Navigator.of(context).pop(true);
            showAlert('Tarea enviada',WalkieTaskColors.color_89BD7D);
          }
        }else{
          showAlert('Seleccionar integrante.',WalkieTaskColors.color_E07676);
        }
      }
    }catch(e){
      print(e.toString());
      showAlert('Error al enviar datos.',WalkieTaskColors.color_E07676);
    }
    enviandoTarea = false;
    setState(() {});
  }

  Future<void> _getGuests() async {
    setState(() {
      loadGuests = true;
    });
    try{
      var response = await connectionHttp.httpGetListGuestsForProjects();
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        if(value['projects'] != null){
          List listHttp = value['projects'];
          listHttp.forEach((element) {
            try{
              bool exist = false;
              element['userprojects'].forEach((userlist) {
                if(userlist['user_id'] == user.id){
                  exist = true;
                }
              });
              if(exist){
                projectAccepted.add(element['id']);
              }
            }catch(e){
              print(e.toString());
              showAlert('Error : ${e.toString()}', WalkieTaskColors.color_E07676);
            }
          });
        }
      }else{
        showAlert('Error al actualizar lista de proyectos, verificar conexión e intentar nuevamente.', WalkieTaskColors.color_E07676);
      }
    }catch(e){
      print(e.toString());
      showAlert('Error al actualizar lista de proyectos, verificar conexión e intentar nuevamente.', WalkieTaskColors.color_E07676);
    }
    if(mounted){
      setState(() {
        loadGuests = false;
      });
    }
  }
}
