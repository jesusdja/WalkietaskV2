import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Chat/ChatMessenger.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Firebase/chatTareasFirebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class ChatForTarea extends StatefulWidget {

  ChatForTarea({this.tareaRes,this.listaCasosRes, this.blocTaskSend});

  final Tarea tareaRes;
  final List<Caso> listaCasosRes;
  final BlocTask blocTaskSend;

  @override
  _ChatForTareaState createState() => _ChatForTareaState();
}

class _ChatForTareaState extends State<ChatForTarea> {

  Tarea tarea;
  ChatTareas chatTarea;
  ChatTareaFirebase chatTareasdb;
  Usuario usuarioResponsable;
  Image imagenUser;
  TextEditingController controllerSend;

  List<Usuario> listUser = new List<Usuario>();

  CollectionReference tareasColeccion = Firestore.instance.collection('Tareas');
  ChatTareaFirebase tareaFB = ChatTareaFirebase();
  final ScrollController listScrollController = new ScrollController();

  AudioPlayer audioPlayer;
  StreamSubscription _durationSubscription;
  Duration _duration;
  bool reproduciendo = false;

  double alto = 0;
  double ancho = 0;

  BlocTask blocTaskSend;

  StreamSubscription streamSubscriptionTaskSend;

  bool edit = false;
  DateTime fechaTask;
  DateTime fechaTaskOld;

  TextEditingController _controllerTitle;
  TextEditingController _controllerDescription;

  UpdateData updateData = new UpdateData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blocTaskSend = widget.blocTaskSend;

    audioPlayer = new AudioPlayer();
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    listenerAudio();

    controllerSend = new TextEditingController();
    tarea = widget.tareaRes;
    fechaTask = DateTime.parse(widget.tareaRes.created_at);
    fechaTaskOld = DateTime.parse(widget.tareaRes.created_at);

    _controllerTitle = TextEditingController(text: tarea.name);
    _controllerDescription = TextEditingController(text: tarea.description);

    chatTareasdb = new ChatTareaFirebase();
    imagenUser = Image.network('$avatarImage');
    inicializarUser();
    inicializar();
    _inicializarPatronBlocTaskSend();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
    _durationSubscription?.cancel();
    streamSubscriptionTaskSend?.cancel();
  }

  SharedPreferences prefs;
  String idMyUser = '0';
  inicializarUser() async {
    prefs = await SharedPreferences.getInstance();
    idMyUser = prefs.getString('unityIdMyUser');
    listUser = await UserDatabaseProvider.db.getAll();
    if(tarea.user_responsability_id != null){
      usuarioResponsable = await UserDatabaseProvider.db.getCodeId(tarea.user_responsability_id.toString());
    }
    setState(() {});
  }

  inicializar() async {
    ChatTareas chatTareaVery = await chatTareasdb.verificarExistencia(tarea.id.toString());
    if(chatTareaVery != null){
      chatTarea = chatTareaVery;
      setState(() {});
    }else{
      ChatTareas chatTarea2 = new ChatTareas(
        id: '',
        idTarea: tarea.id.toString(),
        mensajes: new Map<String,dynamic>()
      );
      ChatTareas chatTareaNew = await chatTareasdb.crearTareaChat(chatTarea2);
      if(chatTareaNew != null){
        chatTarea = chatTareaNew;
        setState(() {});
      }else{
        print('NO CREADO');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorChat,
      appBar: _appBarH(),
      bottomNavigationBar: Container(
        color: colorFondoSend,
        height: alto * 0.08,
        child: _textFieldSend(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                height: alto * 0.8,
                child: _mensajes(),
              ),
              edit ? Container(
                child: _editTarea(),
              ) :
              Container(
                child: _detallesTarea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarH(){

    String correoUSer = '';
    String nombreUser = '';

    if(usuarioResponsable != null){
      if(usuarioResponsable.avatar != null && usuarioResponsable.avatar != ''){
        imagenUser = Image.network('$directorioImage${usuarioResponsable.avatar}');
      }
      if(usuarioResponsable.name != null && usuarioResponsable.name != ''){
        nombreUser = '${usuarioResponsable.name}';
      }
      if(usuarioResponsable.email != null && usuarioResponsable.email != ''){
        correoUSer = '${usuarioResponsable.email}';
      }
    }

    return AppBar(
      actions: <Widget>[
        Container(
          width: ancho,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text('$nombreUser',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018, color: WalkieTaskColors.color_3C3C3C)),
                      Text('$correoUSer',style: WalkieTaskStyles().stylePrimary(size: alto * 0.017, color: WalkieTaskColors.color_969696))
                    ],
                  )
              ),
              imagenUser!= null ?
              Center(
                child: Container(
                  margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.02),
                  decoration: new BoxDecoration(
                    color: WalkieTaskColors.white, // border color
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: alto * 0.025,
                    backgroundColor: Colors.white,
                    backgroundImage: imagenUser.image,
                  ),
                ),
              ) : Container()
            ],
          ),
        )
      ],
      elevation: 0,
      backgroundColor: colorFondoChat,
      leading: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          child: Center(
            child: Container(
              width: ancho * 0.1,
              height: alto * 0.06,
              child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mensajes(){
    return tarea == null ? Container() : Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: tareasColeccion.where("idTarea", isEqualTo: tarea.id.toString()).snapshots(),
        builder: (context,snapshot){
          if (snapshot.data == null){
            return Container();
          }
          if(chatTarea != null){
            chatTarea.mensajes = snapshot.data.documents[0].data['mensajes'];
          }
          return chatTarea != null ? ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: chatTarea.mensajes.length,
            reverse: true,
            controller: listScrollController,
            itemBuilder: (context, index){
              bool izq = false;
              if(chatTarea.mensajes['$index']['from'] != idMyUser){
                izq = true;
              }
              Usuario userFrom;
              for(int x = 0; x < listUser.length; x++){
                if(chatTarea.mensajes['$index']['from'] == listUser[x].id){
                  userFrom = listUser[x];
                  x = listUser.length;
                }
              }
              return _cardSMS(Colors.red,'${chatTarea.mensajes['$index']['texto']}',izq,userFrom);
            },
          ) :
          Container();
        }
      ),
    );
  }

  Widget _cardSMS(Color colorCard, String texto,bool lateralIzq,Usuario userFrom){

    Image imagenAvatar = Image.network('$avatarImage');
    if(userFrom != null && userFrom.avatar != null && userFrom.avatar != ''){
      imagenAvatar = Image.network('$directorioImage${userFrom.avatar}');
    }

    return Container(
      margin: lateralIzq ? EdgeInsets.only(right: ancho * 0.2) : EdgeInsets.only(left: ancho * 0.2),
      //height: MediaQuery.of(context).size.height * 0.05,
      child: Card(
        color: lateralIzq ? Colors.white : colorfondotext,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: CircleAvatar(
                  radius: alto * 0.03,
                  backgroundImage: imagenAvatar.image,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: ancho * 0.04,top: alto * 0.005,bottom: alto * 0.005),
                child: Text(texto,
                  style:TextStyle(color: colorLetrastext,fontWeight: FontWeight.bold)
                  ,textAlign: TextAlign.left,),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldSend(){

    var styleBorder = const OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 0.6),
      borderRadius: const BorderRadius.all(const Radius.circular(15.0),),
    );

    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Center(
              child: Container(
                margin: EdgeInsets.only(left: ancho * 0.08,right: ancho * 0.02),
                child: TextField(
                  controller: controllerSend,
                  style:estiloLetras(alto * 0.025,colortitulo),
                  decoration: new InputDecoration(
                      focusedBorder: styleBorder,
                      enabledBorder: styleBorder,
                      border: styleBorder,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:EdgeInsets.symmetric(horizontal: ancho * 0.05, vertical: alto * 0.01)
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  if(controllerSend.text != ''){

                    DateTime now = DateTime.now();
                    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                    String formattedHours = DateFormat('kk:mm').format(now);

                    ChatMessenger mensaje = new ChatMessenger(
                      fecha: formattedDate,
                      hora: formattedHours,
                      texto: controllerSend.text,
                      from: idMyUser
                    );

                    Map<dynamic,dynamic> Maplista = Map<String,dynamic>();
                    Maplista['0'] = mensaje.toJson();
                    int pos = 1;
                    if(chatTarea.mensajes != null){
                      chatTarea.mensajes.forEach((key,value){
                        Maplista[pos.toString()] = value;
                        pos++;
                      });
                    }

                    await tareaFB.agregarMensaje(chatTarea.id,Maplista);

                    listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                    controllerSend.text = '';
                    setState(() {});
                  }

                },
              ),
            ),
          )

        ],
      ),
    );
  }

  bool verDetalle = true;
  Widget _detallesTarea(){

    String descripcion = '',caso = '', adjunto = '';
    if(tarea != null && tarea.description != null){
      descripcion = tarea.description;
    }
    if(tarea != null && tarea.project_id != null && widget.listaCasosRes != null){
      for(int x = 0; x < widget.listaCasosRes.length; x++){
        caso = widget.listaCasosRes[x].name;
      }
    }
    if(tarea != null && tarea.url_attachment != null && tarea.url_attachment.isNotEmpty){
      adjunto = tarea.url_attachment.replaceAll('%', '/');
      adjunto = adjunto.split('/').last;
      int pos = adjunto.indexOf('U$idMyUser');
      adjunto = adjunto.substring(pos + 3, adjunto.length);
    }
    return Container(
      margin: EdgeInsets.only(left: ancho * 0.02,right: ancho * 0.02,top: alto * 0.01),
      padding: EdgeInsets.all(alto * 0.015),
      width: ancho,
      decoration: new BoxDecoration(
        color: colorfondoDetalle,
        border: Border.all(width: 1,color: colorBordeOpc),
        borderRadius: BorderRadius.all(Radius.circular(10),),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //Titulo
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(tarea.name,
                    style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.027, color: WalkieTaskColors.color_3C3C3C),
                  ),
                ),
                SizedBox(width: ancho * 0.02,),
                tarea.url_audio != '' ?
                InkWell(
                  child: Container(
                      child: Center(
                        child: CircleAvatar(
                          child: Icon(Icons.volume_up,size: alto * 0.03,),
                          foregroundColor: reproduciendo ? Colors.green : WalkieTaskColors.color_969696,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      width: ancho * 0.08,
                      height: ancho * 0.08,
                      padding: const EdgeInsets.all(2.0), // borde width
                      decoration: new BoxDecoration(
                        color: reproduciendo ? Colors.green : WalkieTaskColors.color_969696, // border color
                        shape: BoxShape.circle,
                      )
                  ),
                  onTap: (){
                    audioPlayer.play(tarea.url_audio);
                  },
                ) : Container(),
                verDetalle ? Container() : SizedBox(width: ancho * 0.02,),
                verDetalle ? Container() :
                InkWell(
                  child: Container(
                      child: Center(
                        child: Image.asset(
                          'assets/image/icon_edit.png',
                          //color: WalkieTaskColors.color_969696,
                          fit: BoxFit.fill,
                        ),
                      ),
                      width: ancho * 0.08,
                      height: ancho * 0.08,
                      padding: const EdgeInsets.all(5.0), // borde width
                      decoration: new BoxDecoration(
                        //color: WalkieTaskColors.color_969696, // border color
                        border: Border.all(width: 2,color: WalkieTaskColors.color_969696),
                        shape: BoxShape.circle,
                      ),
                  ),
                  onTap: (){
                    setState(() {
                      edit = true;
                    });
                  },
                ),
              ],
            ),
          ),
          //descripcion
          !verDetalle && descripcion != '' ?
          Container(
            margin: EdgeInsets.only(top:alto * 0.03,bottom: alto * 0.02),
            child: Text(descripcion,style: WalkieTaskStyles().stylePrimary(
              size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C,spacing: 0.5
            )),
          ) : Container(),
          //caso
          !verDetalle && caso != '' ?
          Container(
            margin: EdgeInsets.only(bottom: alto * 0.02),
            width: ancho,
            child: Text('Proyecto: $caso',style: WalkieTaskStyles().styleHelveticaNeueBold(
                size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C,spacing: 0.5
            )),
          ) : Container(),
          //Adjunto
          !verDetalle ? Container() : SizedBox(height: alto * 0.02,),
          Container(
            width: ancho,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                (!verDetalle && adjunto != '') ? Icon(Icons.attach_file,size: alto * 0.02,) : Container(),
                Expanded(
                  child: (!verDetalle && adjunto != '') ? InkWell(
                    child: Text(adjunto,style: WalkieTaskStyles().stylePrimary(
                        size: alto * 0.02, color: WalkieTaskColors.color_969696, spacing: 0.5,
                        fontWeight: FontWeight.bold
                    )),
                    onTap: () async {
                      try{
                        if (await canLaunch(tarea.url_attachment)) {
                          await launch(tarea.url_attachment);
                        } else {
                          throw 'Could not launch ${tarea.url_attachment}';
                        }
                      }catch(e){
                        print(e.toString());
                      }
                    },
                  ) : Container(),
                ),
                Container(
                  width: ancho * 0.1,
                  height: alto * 0.02,
                  child: FittedBox(
                      fit: BoxFit.fill,
                      child: InkWell(
                        child: verDetalle ? Image.asset('assets/image/tri1.png') : Image.asset('assets/image/tri1.1.png'),
                        onTap: (){
                          verDetalle = !verDetalle;
                          setState(() {});
                        },
                      )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editTarea(){

    return Container(
      margin: EdgeInsets.only(left: ancho * 0.02,right: ancho * 0.02,top: alto * 0.01),
      padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01,left: ancho * 0.05, right: ancho * 0.05),
      width: ancho,
      decoration: new BoxDecoration(
        color: colorfondoDetalle,
        border: Border.all(width: 1,color: colorBordeOpc),
        borderRadius: BorderRadius.all(Radius.circular(10),),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: ancho,
            child: Text('Editar tarea',
              style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.027, color: WalkieTaskColors.color_3C3C3C),
            ),
          ),
          SizedBox(height: alto * 0.035,),
          Container(
            width: ancho,
            child: Text('Titulo:',
              style: WalkieTaskStyles().stylePrimary(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
            ),
          ),
          SizedBox(height: alto * 0.008,),
          Container(
            width: ancho,
            child: TextFildGeneric(
              labelStyle: WalkieTaskStyles().stylePrimary(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
              initialValue: null,
              onChanged: (String value) {},
              sizeW: ancho,
              sizeH: alto,
              sizeHeight: alto * 0.045,
              textEditingController: _controllerTitle,
              borderColor: WalkieTaskColors.color_E2E2E2,
              sizeBorder: 1.8,
            ),
          ),
          SizedBox(height: alto * 0.02,),
          Container(
            width: ancho,
            child: Text('Descripción',
              style: WalkieTaskStyles().stylePrimary(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
            ),
          ),
          SizedBox(height: alto * 0.008,),
          Container(
            width: ancho,
            child: TextFildGeneric(
              labelStyle: WalkieTaskStyles().stylePrimary(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
              sizeH: alto,
              sizeW: ancho,
              borderColor: WalkieTaskColors.color_E2E2E2,
              sizeBorder: 1.8,
              textAlign: TextAlign.left,
              initialValue: null,
              sizeHeight: alto * 0.15,
              maxLines: 5,
              textEditingController: _controllerDescription,
              onChanged: (text) {},
            ),
          ),
          SizedBox(height: alto * 0.03,),
          Container(
            width: ancho,
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: ancho * 0.03),
                  child: Text('Fecha',textAlign: TextAlign.right,
                    style: WalkieTaskStyles().stylePrimary(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C, spacing: 1),),
                ),
                Container(
                  width: ancho * 0.5,
                  child: InkWell(
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
                    child: Container(
                      decoration: new BoxDecoration(
                        border: Border.all(width: 1.8,color: WalkieTaskColors.color_E2E2E2),
                        borderRadius: BorderRadius.all(Radius.circular(5.0),),
                      ),
                      child: fechaTask != null ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('${fechaTask.day}-${fechaTask.month}-${fechaTask.year}',
                              style: WalkieTaskStyles().stylePrimary(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C, spacing: 1)),
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
                ),
              ],
            ),
          ),
          SizedBox(height: alto * 0.04,),
          Container(
            width: ancho,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RoundedButton(
                  borderColor: WalkieTaskColors.primary,
                  width: ancho * 0.2,
                  height: alto * 0.04,
                  radius: 5.0,
                  title: 'Aceptar',
                  textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.04, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 2),
                  backgroundColor: WalkieTaskColors.primary,
                  onPressed: () => _saveEditTask(),
                ),
                SizedBox(width: ancho * 0.08,),
                RoundedButton(
                  borderColor: WalkieTaskColors.white,
                  width: ancho * 0.2,
                  height: alto * 0.04,
                  radius: 5.0,
                  title: 'Cancelar',
                  textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.04, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 2),
                  backgroundColor: WalkieTaskColors.white,
                  onPressed: () async{
                    setState(() {
                      edit = false;
                    });
                  },
                )
              ],
            ),
          ),
          SizedBox(height: alto * 0.01,),
        ],
      ),
    );
  }

  Future<void> _saveEditTask() async {
    try{
      conexionHttp connectionHttp = new conexionHttp();
      Map<String,dynamic> body = {
        'name' : '${_controllerTitle.text}',
        'deadline' : fechaTask.toString(),
        //'description' : '${_controllerDescription.text}'
      };
      var response = await connectionHttp.httpUpdateTask(body, tarea.id);
      var value = jsonDecode(response.body);
      if(response.statusCode == 200){
        showAlert('Tarea modificada con exito!',WalkieTaskColors.color_89BD7D);
        updateData.actualizarListaRecibidos(blocTaskSend);
        updateData.actualizarListaEnviados(blocTaskSend);
        setState(() {
          edit = false;
        });
      }else{
        if(value['message'] != null && (value['message'] as String).isNotEmpty){
          showAlert(value['message'],Colors.red[400]);
        }else{
          showAlert('Error al enviar datos.',Colors.red[400]);
        }
      }
    }catch(e){
      print(e.toString());
      showAlert('Error al enviar datos.',Colors.red[400]);
    }
  }

  _inicializarPatronBlocTaskSend(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionTaskSend = blocTaskSend.outList.listen((newVal) {
        if(newVal){
          _inicializarTaskSend();
        }
      });
    } catch (e) {}
  }
  _inicializarTaskSend() async {
    tarea = await TaskDatabaseProvider.db.getCodeId(tarea.id.toString());
    setState(() {});
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
          //pause = true;
          reproduciendo = false;
          _durationPause = Duration(seconds: 0);
        });
      }
      if(AudioPlayerState.PAUSED == s){
        //pause = true;
        reproduciendo = false;
        setState(() {});
      }
      if(AudioPlayerState.PLAYING == s){
        if(oldState == AudioPlayerState.COMPLETED){
          _resetSoundPause();
        }
        //pause = false;
        reproduciendo = true;
        setState(() {});
        _contMinutePause();
      }
      oldState = s;
      if(AudioPlayerState.STOPPED == s){
        oldState = AudioPlayerState.COMPLETED;
      }
    });
  }

  void _resetSoundPause(){
    minutos = '00';
    segundos = '00';
    mostrarMinutosEspera = 0;
    segundoEspera = 0;
    reproduciendo = false;
    setState(() {});
  }

  int mostrarMinutosEspera = 0;
  int segundoEspera = 0;
  String minutos = '00';
  String segundos = '00';

  Future<void> _contMinutePause() async {
    if(reproduciendo){
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

}
