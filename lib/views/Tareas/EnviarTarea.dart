import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/avatar_widget.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/upload_background_documents.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import '../../utils/Cargando.dart';


class EnviarTarea extends StatefulWidget {

  EnviarTarea({
    @required this.blocUserRes,
    @required this.listUserRes,
    @required this.myUserRes,
    @required this.listaCasosRes,
    @required this.blocTaskReceived,
    @required this.blocTaskSend,
    @required this.blocIndicatorProgress});

  final List<Usuario> listUserRes;
  final BlocUser blocUserRes;
  final Usuario myUserRes;
  final List<Caso> listaCasosRes;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;
  final BlocProgress blocIndicatorProgress;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<EnviarTarea> {

  FlutterSound flutterSound = new FlutterSound();
  StreamSubscription _recorderSubscription;
  AudioPlayer audioPlayer;
  AudioCache audioCache;
  StreamSubscription _durationSubscription;
  Duration _duration;
  StreamSubscription streamSubscriptionUser;
  Usuario userSeleccionado;

  bool grabado = false;
  String audioName = 'audioplay';
  String audioPath;
  double alto = 1;
  double ancho = 1;
  TextEditingController controlleBuscador;
  TextEditingController controlleBuscadorCasos;
  TextEditingController controlletituloTarea;
  TextEditingController controlleExplicacion;

  Map<int,bool> tareaText = Map<int,bool>();
  List<String> listIntegrantes = new List<String>();
  List<Usuario> listUser;
  BlocUser blocUser;
  Map<int,bool> mapUserSelect = Map();

  TextStyle textStylePrimary;
  TextStyle textStylePrimaryBold;

  BlocProgress blocIndicatorProgress;

  @override
  void initState() {

    listUser = widget.listUserRes;
    blocUser = widget.blocUserRes;

    controlleBuscador = new TextEditingController();
    controlleBuscadorCasos = new TextEditingController();
    controlletituloTarea = new TextEditingController();
    controlleExplicacion = new TextEditingController();
    controlletituloTarea.text = '';
    controlleExplicacion.text = '';

    tareaText[0] = true;
    tareaText[1] = false;

    pathinicial();

    super.initState();
    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);

    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
      print('$_duration');
    });

    blocIndicatorProgress = widget.blocIndicatorProgress;

    listenerAudio();
    //_inicializarPatronBlocUser();
  }

  void dispose() {
    audioPlayer.stop();
    _durationSubscription?.cancel();
    streamSubscriptionUser?.cancel();
    super.dispose();
  }

  String appDocPath = '';
  bool cargando = true;
  pathinicial() async{
    Directory appDocDi25 = await getExternalStorageDirectory();
    appDocPath = appDocDi25.path;
    cargando = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;
    listUser = widget.listUserRes;

    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.024, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.024, color: WalkieTaskColors.color_969696);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: WalkieTaskColors.white,
        body: cargando ? Cargando('Cargando',context) : contenido(),
      ),
    );
  }

  Widget contenido(){
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: alto * 0.08,
              child: _bottonAudioText(),
            ),
            Container(
              height: alto * 0.06,
              child: buscador(),
            ),
            Container(
              height: alto * 0.33,
              child: integrantes(),
            ),
            Container(
              margin: EdgeInsets.only(top: alto * 0.02,right: ancho * 0.05,bottom: alto * 0.01),
              width: ancho * 0.85,
              child: Text('Titulo (opcional)',textAlign: TextAlign.left,
                  style: textStylePrimary),
            ),
            _tituloTarea(),
            Container(
              margin: EdgeInsets.only(left: ancho * 0.05,right: ancho * 0.05),
              width: ancho,
              child: _opcAvanz(),
            ),
            tareaText[0] ? Container(
              child: grabador(),
            ) : Container(),
            tareaText[1] ? Container(height: alto * 0.015,) : Container(),
            tareaText[1] ? Container(
              margin: EdgeInsets.only(left: ancho * 0.1,right: ancho * 0.05),
              width: ancho,
              child: _sumitTexto(),
            ) : Container(),
            tareaText[1] ? Container(height: alto * 0.022,) : Container(),
          ],
        ),
      ),
    );
  }

  Widget _bottonAudioText(){
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buttonAT('Audio',tareaText[0],1),
          buttonAT('Texto',tareaText[1],0),
        ],
      ),
    );
  }

  Widget buttonAT(String texto, bool value,int tipo){
    return InkWell(
      child: Container(
        height: alto * 0.04,
        width: ancho * 0.22,
        decoration: new BoxDecoration(
            color: value ? colorButtonBlueAT : Colors.white,
            boxShadow: [ BoxShadow(color: colorBordeOpc,spreadRadius: 1)],
            borderRadius: BorderRadius.only(
                bottomRight: tipo == 1 ? const Radius.circular(0) : const Radius.circular(40.0),
                topRight: tipo == 1 ? const Radius.circular(0) : const Radius.circular(40.0),
                bottomLeft: tipo == 1 ? const Radius.circular(40.0) : const Radius.circular(0),
                topLeft: tipo == 1 ? const Radius.circular(40.0) : const Radius.circular(0)
            )
        ),
        child: Center(child: textAT(texto,value),),
      ),
      onTap: (){
        _reiniciarSonido();
        _reiniciarVariables();
        tareaText[0] = !tareaText[0];
        tareaText[1] = !tareaText[1];
        setState(() {});
      },
    );
  }

  textAT(String texto,bool status){
    return Text('$texto',
        style: estiloLetras(17,status ? Colors.white : colorletrasbuttonAT)
    );
  }

  bool iconBuscador = false;
  Widget buscador(){
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: ancho * 0.05),
            child: Text('Buscar',style: textStylePrimary),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: ancho * 0.03,right: ancho * 0.05),
              height: alto * 0.04,
              child: TextFildGeneric(
                onChanged: (text) {
                  //controlleBuscador.text = value;
                  if(text.length > 0){
                    iconBuscador = true;
                  }else{
                    iconBuscador = false;
                  }
                  setState(() {});
                },
                labelStyle: textStylePrimary,
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_E2E2E2,
                sizeBorder: 1.8,
                sizeHeight: alto * 0.045,
                textAlign: TextAlign.left,
                suffixIcon: InkWell(
                  child: iconBuscador ? Icon(Icons.clear) : Icon(Icons.search),
                  onTap: (){
                    if(iconBuscador){
                      //controlleBuscador.text = '';
                      iconBuscador = false;
                      //controlleBuscador.clear();
                      WidgetsBinding.instance.addPostFrameCallback((_) => controlleBuscador.clear());
                      setState(() {});
                    }
                  },
                ),
                textEditingController: controlleBuscador,
                initialValue: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget integrantes(){

    bool userSelect = false;
    if(mapUserSelect[0] != null && mapUserSelect[0]){
      userSelect = true;
    }

    Image avatarUser = Image.network(avatarImage);
    if(widget.myUserRes != null){
      if(widget.myUserRes.avatar != null && widget.myUserRes.avatar != ''){
        avatarUser = Image.network('$directorioImage${widget.myUserRes.avatar}');
      }
    }

    return Container(
      margin: EdgeInsets.only(left: ancho * 0.05,right: ancho * 0.05),
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        border: new Border.all(
          width: 2,
          color: WalkieTaskColors.color_E2E2E2,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            InkWell(
              child: Container(
                color: userSelect ? colorfondoSelectUser : Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: ancho * 0.05),
                        child: Text('Recordatorio Personal',textAlign: TextAlign.right,
                          style: userSelect ? textStylePrimaryBold : textStylePrimary,
                        ),
                      ),
                    ),
                    avatarCirculeImage(
                        WalkieTaskColors.grey,
                        avatarUser,
                        ancho * 0.05
                    ),
                  ],
                ),
              ),
              onTap: (){
                Usuario usuario = new Usuario(id: 0);
                if(mapUserSelect[usuario.id] == null){mapUserSelect[usuario.id] = false;}

                mapUserSelect.forEach((key,value){
                  if(key == usuario.id){
                    mapUserSelect[usuario.id] = !mapUserSelect[usuario.id];
                    if(mapUserSelect[usuario.id]){userSeleccionado = usuario;}else{userSeleccionado = null;}
                  }else{
                    mapUserSelect[key] = false;
                  }
                });
                setState(() {});
              },
            ),
            Container(
              height: alto * 0.25,
              margin: EdgeInsets.only(bottom: alto * 0.025),
              child: listUser == null ? Container() :
              ListView.builder(
                itemCount: listUser.length,
                itemBuilder: (context,index){

                  Usuario usuario = listUser[index];

                  if((usuario != null && widget.myUserRes != null && usuario.id == widget.myUserRes.id) ||
                     (usuario.contact == 0) ||
                     (usuario != null && controlleBuscador.text.length != 0 && !usuario.name.toLowerCase().contains(controlleBuscador.text.toLowerCase()))){
                    return Container();
                  }

                  var imagenAvatar = Image.network(avatarImage);
                  if(usuario != null && usuario.avatar != ''){
                    try{
                      imagenAvatar = Image.network('$directorioImage${usuario.avatar}');
                    }catch(e){
                      print('No cargo imagen');
                    }
                  }

                  bool userSelect = false;
                  if(usuario != null && mapUserSelect[usuario.id] != null && mapUserSelect[usuario.id]){
                    userSelect = true;
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: alto * 0.002),
                    color: userSelect ? colorfondoSelectUser : Colors.white,
                    child: InkWell(
                      onTap: (){
                        if(mapUserSelect[usuario.id] == null){mapUserSelect[usuario.id] = false;}

                        mapUserSelect.forEach((key,value){
                          if(key == usuario.id){
                            mapUserSelect[usuario.id] = !mapUserSelect[usuario.id];
                            if(mapUserSelect[usuario.id]){userSeleccionado = usuario;}else{userSeleccionado = null;}
                          }else{
                            mapUserSelect[key] = false;
                          }
                        });
                        setState(() {});
                      },
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: alto * 0.006,bottom: alto * 0.006),
                              child: CircleAvatar(
                                radius: ancho * 0.05,
                                backgroundColor: colorButtonBlueAT,
                                child: usuario.avatar == '' ?
                                Text('${usuario.name.toUpperCase().substring(0,1)}',style: TextStyle(fontSize: alto * 0.028,fontWeight: FontWeight.bold,color: Colors.white),) :  Container(),
                                backgroundImage: usuario.avatar == '' ? null : imagenAvatar.image,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: ancho * 0.65,
                                margin: EdgeInsets.only(left: ancho * 0.05),
                                child: Text('${usuario.name}',
                                  style: userSelect ? textStylePrimaryBold : textStylePrimary,
                                ),
                              ),
                            ),
                            Container(
                              child: usuario.fijo == 0 ? Container() :
                              Container(
                                width: ancho * 0.04,
                                height: alto * 0.03,
                                child: Image.asset('assets/image/pinOn.png',fit: BoxFit.fill,
                                  color: Colors.grey,),
                              ),
                            ),
                          ],
                        ),
                        secondaryActions: <Widget>[
                          _buttonSliderAction(usuario),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonSliderAction(Usuario usuario){
    return IconSlideAction(
      color: usuario.fijo == 1 ? Colors.red : Colors.blueAccent,
      iconWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(usuario.fijo == 1 ? 'Liberar' : ' Fijar ',
            style: estiloLetras(alto * 0.022,Colors.white),),
          SizedBox(width: ancho * 0.012,),
          Image.asset('assets/image/pinOn.png',width: ancho * 0.05,height: ancho * 0.06),
        ],
      ),
      onTap: () async {

        int res = 0;
        if(usuario.fijo == 1){
          usuario.fijo = 0;
        }else{
          usuario.fijo = 1;
        }
        res = await  UserDatabaseProvider.db.updateUser(usuario);
        if(res == 1){
          blocUser.inList.add(true);
        }
      },
    );
  }

  //*******************************************************
  //*******************************************************
  //*******************************************************
  //*********************TAREA SONIDO**********************
  //*******************************************************
  //*******************************************************
  //*******************************************************

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
          !enviar ? Container(
            width: ancho * 0.28,
            height: alto * 0.14,
            margin: EdgeInsets.only(left: ancho * 0.08),
            child: _buttonRed(),
          ) :
          Container(
            width: ancho * 0.28,
            height: alto * 0.14,
            margin: EdgeInsets.only(left: ancho * 0.08),
            child: enviandoTarea ?
            Center(child: CircularProgressIndicator(),) : botonEnviar(),
          ),
        ],
      ),
    );
  }

  //*******************************************************
  //*******************************************************
  //*******************************************************
  //*********************TAREA TEXTO***********************
  //*******************************************************
  //*******************************************************
  //*******************************************************

  String titleTask = '';
  Widget _tituloTarea(){
    return Container(
      padding: EdgeInsets.only(left: ancho * 0.05,right: ancho * 0.05),
      height: alto * 0.04,
      child: TextFildGeneric(
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
        textEditingController: controlletituloTarea,
        initialValue: null,
      ),
    );
  }

  bool opcionesOpen = false;
  DateTime fechaTask;
  String _pathAdjunto;
  String _fileNameAdjunto = '';
  String descriptionTask = '';

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
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01),
            child: _buscadorCasos(),
          ),
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01),
            child: _listadocasos(),
          ),
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01),
            child: Text('Descripción adicional',textAlign: TextAlign.left,
                style: textStylePrimary),
          ),
          //EXPLICACION ADICIONAL
          !opcionesOpen ? Container() : Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.01),
            child: TextFildGeneric(
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
              sizeBorder: 1.8,
              textAlign: TextAlign.left,
              textEditingController: controlleExplicacion,
              initialValue: null,
              sizeHeight: alto * 0.2,
              maxLines: 5,
            ),
          ),
          !opcionesOpen ? Container() : SizedBox(height: alto * 0.02,),
          //FECHA
          InkWell(
            child: !opcionesOpen ? Container() :
            Container(
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
                    child: Container(
                      height: alto * 0.045,
                      decoration: new BoxDecoration(
                        border: Border.all(width: 1,color: colorBordeOpc),
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
                  )
                ],
              ),
            ),
            onTap: () async {
              DateTime newDateTime = await showRoundedDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 1),
                  borderRadius: 20,
                  height: MediaQuery.of(context).size.height * 0.6,
              );
              if (newDateTime != null) {
                setState(() => fechaTask = newDateTime);
              }
            },
          ),
          !opcionesOpen ? Container() : SizedBox(height: alto * 0.02,),
          //ADJUNTO
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
                        style: textStylePrimary),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      height: alto * 0.045,
                      decoration: new BoxDecoration(
                        border: Border.all(width: 1,color: colorBordeOpc),
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
          ),
          !opcionesOpen ? Container() : SizedBox(height: alto * 0.02,),
        ],
      ),
    );
  }

  bool iconBuscadorCasos = false;
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
                  if(text.length > 0){
                    iconBuscadorCasos = true;
                  }else{
                    iconBuscadorCasos = false;
                  }
                  setState(() {});
                },
                labelStyle: textStylePrimary,
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_E2E2E2,
                sizeBorder: 1.8,
                sizeHeight: alto * 0.045,
                textAlign: TextAlign.left,
                suffixIcon: InkWell(
                  child: iconBuscador ? Icon(Icons.clear) : Icon(Icons.search),
                  onTap: (){
                    if(iconBuscadorCasos){
                      iconBuscadorCasos = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) => controlleBuscadorCasos.clear());
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

  Map<int,bool> mapcasoSelect = Map();
  Caso casoSeleccionado;

  Widget _listadocasos(){
    bool seleccionado = false;
    if((mapcasoSelect[0] != null && mapcasoSelect[0])){
      seleccionado = true;
    }
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        border: new Border.all(
          width: 2,
          color: WalkieTaskColors.color_E2E2E2,
        ),
      ),
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
          ),
          SizedBox(height: alto * 0.01,),
          Container(
            height: tareaText[1] ? alto * 0.35 : alto * 0.23,
            child: widget.listaCasosRes == null ? Container() : ListView.builder(
              itemCount: widget.listaCasosRes.length,
              itemBuilder: (context,index){

                Caso caso = widget.listaCasosRes[index];
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
                        Text('${caso.name}',style: userSelect ? textStylePrimaryBold : textStylePrimary),
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

  UpdateData updateData = new UpdateData();
  bool enviandoTarea = false;
  Widget _sumitTexto(){
    return
      InkWell(
        onTap: () async => _sendTask(),
        child: Container(
          height: alto * 0.14,
          width: ancho,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: alto * 0.15,
              height: alto * 0.15,
              decoration: enviandoTarea ? null : BoxDecoration(
                image: DecorationImage(
                  image: ViewImage().assetsImage("assets/image/SendTask.png").image,
                  fit: BoxFit.fill,
                ),
              ),
              child: enviandoTarea ?
              Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorButtonBlueAT,)),
              ) : Container(),
            ),
          ),
        ),
      );
    /*Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: InkWell(
              child: Container(
                width: ancho,
                height: alto * 0.045,
                decoration: new BoxDecoration(
                  color: colorButtonBlueAT,
                  borderRadius: BorderRadius.all(Radius.circular(10),),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Enviar ",
                        style: estiloLetras(alto * 0.022,Colors.white)),
                    Container(
                      height: alto * 0.025,
                      child: Image.asset('assets/image/SendTask2.png',color: Colors.white,),
                    )
                  ],
                ),
              ),
              onTap: () async {

                enviandoTarea = true;
                setState(() {});

                Tarea tarea = await _crearTarea();

                bool res = await sendTask(tarea);
                if(res){
                  updateData.actualizarListaRecibidos(widget.blocTaskReceived);
                  updateData.actualizarListaEnviados(widget.blocTaskSend);
                  _reiniciarVariables();
                  showAlert('SE ENVIO',Colors.green[600]);
                }else{
                  showAlert('NO SE ENVIO',Colors.red[400]);
                }

                enviandoTarea = false;
                setState(() {});

              },
            ),
          ),
          Expanded(flex: 1,child: Container(),),
          Expanded(
            flex: 5,
            child: InkWell(
              child: Container(
                height: alto * 0.045,
                //width: ancho,
                decoration: new BoxDecoration(
                  color: colorButtonBlueAT,
                  borderRadius: BorderRadius.all(Radius.circular(10),),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text("Asignar a caso",
                        style: estiloLetras(alto * 0.02,Colors.white)),
                    Icon(Icons.arrow_forward_ios,color: Colors.white,size: alto * 0.03,)
                  ],
                ),
              ),
              onTap: () async {

                enviandoTarea = true;
                setState(() {});

                Tarea tarea = await _crearTarea();

                enviandoTarea = false;
                setState(() {});

                final result = await Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new AsignarCaso(myUserRes: widget.myUserRes,pathAudioRes: '$appDocPath/$audioName.mp4',listaCasosRes: widget.listaCasosRes,isTextoRes: true,tareaRes: tarea,blocTaskSend: widget.blocTaskSend,blocTaskReceived: widget.blocTaskReceived,)));

                if(result['enviado']){
                  _reiniciarVariables();
                }
              },
            ),
          ),

        ],
      ),
    );*/
  }

  // Future<Tarea> _crearTarea() async {
  //   Tarea tareaRes;
  //
  //   String fecha = fechaTask != null ? '${fechaTask.year}-${fechaTask.month}-${fechaTask.day}' : '';
  //
  //   int id_user_responsability;
  //   if(userSeleccionado != null){
  //     id_user_responsability = userSeleccionado.id == 0 ? widget.myUserRes.id : userSeleccionado.id;
  //   }
  //
  //   String phat = '';
  //   if(_pathAdjunto != null){
  //     Map<String,String> mapArchivo = await subirArchivo(_pathAdjunto,_fileNameAdjunto);
  //     if(mapArchivo['subir'] == 'true'){
  //       phat = mapArchivo['location'];
  //     }
  //   }
  //
  //   tareaRes = new Tarea(
  //       name: controlletituloTarea.text,
  //       deadline: fecha,
  //       reminder_type_id: 1,
  //       user_id: widget.myUserRes.id,
  //       user_responsability_id: id_user_responsability,
  //       status_id: 1,
  //       description: controlleExplicacion.text,
  //       url_attachment: phat
  //   );
  //
  //   return tareaRes;
  // }

  _reiniciarVariables(){
    mapUserSelect.clear();
    controlletituloTarea.text = '';
    controlleExplicacion.text = '';
    fechaTask = null;
    _pathAdjunto = null;
    _fileNameAdjunto = '';
    audioPath = null;
    descriptionTask = '';
    titleTask = '';
    opcionesOpen = false;

    mapcasoSelect = {};

    setState(() {});
  }
  _reiniciarSonido(){
    enviar = false;
    minutos = '00';
    segundos = '00';
    mostrarMinutosEspera = 0;
    segundoEspera = 0;
    reproduciendo = false;
    audioPath = null;
    setState(() {});
  }
  void _resetSoundPause(){
    minutos = '00';
    segundos = '00';
    mostrarMinutosEspera = 0;
    segundoEspera = 0;
    setState(() {});
  }

  //*******************************************************
  //*******************************************************
  //*******************************************************
  //*********************GRABAR****************************
  //*******************************************************
  //*******************************************************
  //*******************************************************

  bool grabando = false;
  bool enviar = false;
  Widget _buttonRed(){
    return GestureDetector(
      onTapUp: (va){
        setState(() {
          grabando = false;
          enviar = true;
        });
        detenergrabar();
      },
      onTapDown: (va){
        setState(() {
          grabando = true;
        });
        _contMinute();
        grabarSound();
      },
      child: grabando ? Container(
        width: alto * 0.15,
        height: alto * 0.15,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ViewImage().assetsImage("assets/image/micOn.png").image,
            fit: BoxFit.fill,
          ),
        ),
      ) :
      Container(
        width: alto * 0.15,
        height: alto * 0.15,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ViewImage().assetsImage("assets/image/micOff.png").image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
  grabarSound() async {
    try {
      //String path = await flutterSound.startRecorder('/storage/emulated/0/$ruta.mp4');
      // /storage/emulated/0/Android/data/com.conexion.grabarsonido2/files/Get2.mp4
      //String path = await flutterSound.startRecorder('$appDocPath/jesus.mp4');
      DateTime date = DateTime.now();
      audioName = 'audioplay${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}';
      audioPath = '$appDocPath/$audioName.mp4';
      setState(() {});
      String path = await flutterSound.startRecorder('$appDocPath/$audioName.mp4');

      print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        //DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        //String txt = '${date.minute}:${date.second}:${date.millisecond}';//DateFormat('mm:ss:SS', 'en_US').format(date);
        //print(date.millisecond.toString());
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }
  detenergrabar() async {
    String result = await flutterSound.stopRecorder();
    print('stopRecorder: $result');

    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
      setState(() {
        grabado = true;
      });
    }
  }


  //*******************************************************
  //*******************************************************
  //*******************************************************
  //******************DESPUES DE GRABADO*******************
  //*******************************************************
  //*******************************************************
  //*******************************************************

  botonEnviar(){
    return GestureDetector(
      onTap: () => _sendTask(),
      child: Container(
        width: alto * 0.15,
        height: alto * 0.15,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ViewImage().assetsImage("assets/image/SendTask.png").image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  //*******************************************************
  //*******************************************************
  //*******************************************************
  //******************REPRODUCIR***************************
  //*******************************************************
  //*******************************************************
  //*******************************************************

  int mostrarMinutosEspera = 0;
  int segundoEspera = 0;
  String minutos = '00';
  String segundos = '00';
  bool pause = false;
  Future<void> _contMinute() async {
    if(grabando){
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
      _contMinute();
    }
  }

  Future<void> _contMinutePause() async {
    if(!pause){
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
      _contMinutePause();
    }
  }

  Duration _durationPause = Duration(seconds: 0);
  Future<void> listenerAudio() async {
    audioPlayer.onAudioPositionChanged.listen((Duration  p){
      print('Current position: $p');
      _durationPause = p;
      // int s = _durationPause.inSeconds;
      // segundos = s.toString();
      // minutos = _durationPause.inMinutes.toString();
      // setState(() {});
    });
    AudioPlayerState oldState = AudioPlayerState.COMPLETED;
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      print('Current player state: $s');
      if(AudioPlayerState.COMPLETED == s){
        setState(() {
          pause = true;
          reproduciendo = false;
          _durationPause = Duration(seconds: 0);
        });
      }
      if(AudioPlayerState.PAUSED == s){
        pause = true;
        setState(() {});
      }
      if(AudioPlayerState.PLAYING == s){
        if(oldState == AudioPlayerState.COMPLETED){
          _resetSoundPause();
        }
        pause = false;
        setState(() {});
        _contMinutePause();
      }
      oldState = s;

      if(AudioPlayerState.STOPPED == s){
        oldState = AudioPlayerState.COMPLETED;
      }
    });
  }

  bool reproduciendo = false;
  botonPlay(){
    Image imagen;

    if(enviar){
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
      onTap: () async {
        if(enviar){
          if(!reproduciendo){
            audioPlayer.play('$appDocPath/$audioName.mp4',isLocal: true,position: _durationPause);
          }else{
            await audioPlayer.pause();
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

    if(enviar){
      imagen = Image.asset('assets/image/deleteOpa.png',width: ancho * 0.3,);
    }else{
      imagen = Image.asset('assets/image/deleteOff.png',width: ancho * 0.3,);
    }

    return InkWell(
      child: Container(
        child: imagen,
      ),
      onTap: (){
        if(enviar){
          audioPlayer.stop();
          setState(() {
            enviar = false;
            reproduciendo = false;
            minutos = '00';
            segundos = '00';
            mostrarMinutosEspera = 0;
            segundoEspera = 0;
            audioPath = null;
          });
        }
      },
    );
  }


  //*******************************************************
  //*******************************************************
  //*******************************************************
  //******************ENVIAR TAREA*************************
  //*******************************************************
  //*******************************************************
  //*******************************************************
  void _sendTask() async {
    enviandoTarea = true;
    setState(() {});
    //await Future.delayed(Duration(seconds: 3));

    try{
      //VERIFICAR SI SE SELECCIONO UN INTEGRANTE
      int userSend;
      mapUserSelect.forEach((key, value) {
        if(value){ userSend = key;}
      });
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
        if(audioPath != null && tareaText[0]){
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
        //ENVIAR A SEGUNDO PLANO
        await SharedPrefe().setStringListValue('WalListDocument',listShared);
        uploadBackDocuments(blocIndicatorProgress);
        _reiniciarVariables();
        _reiniciarSonido();
        showAlert('Tarea enviada',WalkieTaskColors.color_89BD7D);
      }else{
        showAlert('Seleccionar integrante.',WalkieTaskColors.color_E07676);
      }
    }catch(e){
      print(e.toString());
      showAlert('Error al enviar datos.',WalkieTaskColors.color_E07676);
    }






    // Tarea tarea = await _crearTarea();
    //
    // String phat = '';
    // if(_pathAdjunto != null){
    //   Map<String,String> mapArchivo = await subirAudio('$appDocPath/$audioName.mp4','$audioName.mp4');
    //   if(mapArchivo['subir'] == 'true'){
    //     phat = mapArchivo['location'];
    //     tarea.url_audio = phat;
    //   }
    // }

    // final result = await Navigator.push(context, new MaterialPageRoute(
    //     builder: (BuildContext context) =>
    //     new AsignarCaso(myUserRes: widget.myUserRes,pathAudioRes: '$appDocPath/$audioName.mp4',listaCasosRes: widget.listaCasosRes,isTextoRes: false,tareaRes: tarea,blocTaskSend: widget.blocTaskSend,blocTaskReceived: widget.blocTaskReceived,)));
    //
    // if(!result['sonido']){
    //   _reiniciarSonido();
    // }
    // if(result['enviado']){
    //   _reiniciarVariables();
    // }

    enviandoTarea = false;
    setState(() {});
  }


  // _inicializarPatronBlocUser(){
  //   try {
  //     // ignore: cancel_subscriptions
  //     streamSubscriptionUser = blocUser.outList.listen((newVal) {
  //       if(newVal){
  //         _inicializarUser();
  //       }
  //     });
  //   } catch (e) {}
  // }
  //
  // _inicializarUser() async {
  //   listUser = await  UserDatabaseProvider.db.getAll();
  //   setState(() {});
  // }
}