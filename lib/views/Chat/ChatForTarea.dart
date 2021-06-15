import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Chat/ChatMessenger.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Firebase/Notification/http_notifications.dart';
import 'package:walkietaskv2/services/Firebase/chatTareasFirebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/provider/language_provider.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/utils/download_file.dart';

class ChatForTarea extends StatefulWidget {

  ChatForTarea({this.tareaRes,this.listaCasosRes, this.blocTaskSend, this.isChat, this.chat});

  final Tarea tareaRes;
  final List<Caso> listaCasosRes;
  final BlocTask blocTaskSend;
  final bool isChat;
  final Map<String,dynamic> chat;

  @override
  _ChatForTareaState createState() => _ChatForTareaState();
}

class _ChatForTareaState extends State<ChatForTarea> {

  Tarea tarea;
  ChatTareas chatTarea;
  ChatTareaFirebase chatTareasdb;
  Usuario usuarioResponsable;
  Image imagenUser;
  Image avatarUser;

  List<Usuario> listUser = new List<Usuario>();

  CollectionReference tareasColeccion;
  ChatTareaFirebase tareaFB;
  final ScrollController listScrollController = new ScrollController();

  AudioPlayer audioPlayer;
  StreamSubscription _durationSubscription;
  bool reproduciendo = false;

  double alto = 0;
  double ancho = 0;

  BlocTask blocTaskSend;

  StreamSubscription streamSubscriptionTaskSend;

  bool edit = false;
  bool viewAppBar = true;

  DateTime fechaTask;
  DateTime fechaTaskOld;
  TextEditingController _controllerChatSms;
  TextEditingController _controllerTitle;
  TextEditingController _controllerDescription;

  UpdateData updateData = new UpdateData();

  bool isChat = false;
  Map<String,dynamic> chat = {};
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    blocTaskSend = widget.blocTaskSend;

    isChat = widget.isChat ?? false;
    chat = widget.chat ?? {};

    audioPlayer = new AudioPlayer();
    listenerAudio();

    try{
      tareasColeccion = FirebaseFirestore.instance.collection('Tareas');
      tareaFB = ChatTareaFirebase();
    }catch(e){
      print(e.toString());
    }

    tarea = widget.tareaRes;
    fechaTask = widget.tareaRes.deadline.isEmpty ? null : DateTime.parse(widget.tareaRes.deadline);
    fechaTaskOld = widget.tareaRes.deadline.isEmpty ? null :  DateTime.parse(widget.tareaRes.deadline);

    _controllerTitle = TextEditingController(text: tarea.name);
    _controllerDescription = TextEditingController(text: tarea.description);
    _controllerChatSms = TextEditingController();

    chatTareasdb = new ChatTareaFirebase();
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

  String idMyUser = '0';
  inicializarUser() async {
    idMyUser = await SharedPrefe().getValue('unityIdMyUser');
    listUser = await DatabaseProvider.db.getAllUser();

    int idSearch;
    if(tarea.user_id.toString() == idMyUser){
      idSearch = tarea.user_responsability_id;
    }else{
      idSearch = tarea.user_id;
    }

    if(tarea.user_responsability_id != null){
      usuarioResponsable = await DatabaseProvider.db.getCodeIdUser(idSearch.toString());
      if(usuarioResponsable != null && usuarioResponsable.avatar_100 != null && usuarioResponsable.avatar_100.isNotEmpty){
        imagenUser = Image.network(usuarioResponsable.avatar_100);
      }
    }

    getPhoto();

    setState(() {});
  }

  Future<void> getPhoto() async {
    avatarUser = await getPhotoUser();
    setState(() {});
  }

  inicializar() async {
    await SharedPrefe().setIntValue('openTask', tarea.id);

    try{
      ChatTareas chatTareaVery = await chatTareasdb.verificarExistencia(tarea.id.toString());
      if(chatTareaVery != null){
        chatTarea = chatTareaVery;
        setState(() {});
      }else{
        String idUser = widget.tareaRes.user_id.toString();

        String idUserFrom = '';
        if(widget.tareaRes.user_id != widget.tareaRes.user_responsability_id){
          idUserFrom = tarea.user_responsability_id.toString();
        }
        Usuario usuarioFrom = await DatabaseProvider.db.getCodeIdUser(widget.tareaRes.user_responsability_id.toString());
        ChatTareas chatTarea2 = new ChatTareas(
          id: '',
          idTarea: tarea.id.toString(),
          idUser: '$idUser',
          idFromUser: idUserFrom,
          mensajes: new Map<String,dynamic>(),
          task: widget.tareaRes.toMap(),
          userFrom: usuarioFrom.toMap(),
        );
        ChatTareas chatTareaNew = await chatTareasdb.crearTareaChat(chatTarea2);
        if(chatTareaNew != null){
          chatTarea = chatTareaNew;
          setState(() {});

        }else{
          print('NO CREADO');
        }
      }

      if(isChat){
        goToSms(chatTarea.mensajes);
      }
    }catch(_){}
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        buttonSend = textChatSend.isNotEmpty;
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: colorChat,
        appBar: viewAppBar ? _appBarH() : null,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: alto * 0.07, top: alto * 0.13),
                child: _mensajes(),
              ),
              edit ? Container(
                child: _editTarea(context),
              ) :
              Container(
                child: _detallesTarea(),
              ),
              Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: colorFondoSend,
                      //height: alto * 0.07,
                      constraints: BoxConstraints(minHeight: alto * 0.07,maxHeight: alto * 0.15),
                      child: _textFieldSend(),
                    )
                ),
              ),
              _one == 0 ? Container() : Positioned(
                left: 0,
                right: 0,
                top: _one,
                height: alto,
                child: GestureDetector(
                  onPanEnd: (details){
                    if(_one > (-alto + 400)){
                      _one = -0.1;
                      _oneFixed = -alto;
                      setState(() {});
                    }
                  },
                  onPanUpdate: (details) {
                    if(_one != 0){
                      _one += details.delta.dy;
                      if (_one > 0){
                        _one = 0.1;
                      }
                      if (_one <= _oneFixed){
                        _one = _oneFixed;
                      }
                      if(_one < (-alto + 400)){
                        _one = 0;
                        _top = false;
                        viewAppBar = true;
                      }
                      setState(() {});
                    }
                  },
                  child: _myContainer(),
                ),
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
      if(usuarioResponsable.avatar_100 != null && usuarioResponsable.avatar_100 != ''){
        imagenUser = Image.network(usuarioResponsable.avatar_100);
      }
      if(usuarioResponsable.name != null && usuarioResponsable.name != ''){
        nombreUser = '${usuarioResponsable.name} ${usuarioResponsable.surname}';
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
                      Text('$correoUSer',style: WalkieTaskStyles().stylePrimary(size: alto * 0.017, color: WalkieTaskColors.color_969696,spacing: 1.2,fontWeight: FontWeight.bold))
                    ],
                  )
              ),

              Center(
                child: Container(
                  margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.02),
                  decoration: new BoxDecoration(
                    color: WalkieTaskColors.white, // border color
                    shape: BoxShape.circle,
                  ),
                  child: imagenUser!= null ? CircleAvatar(
                    radius: alto * 0.025,
                    backgroundColor: Colors.white,
                    backgroundImage: imagenUser.image,
                  ) : avatarWidget(alto: alto, radius: 0.025, text: nombreUser.isEmpty ? '' : nombreUser.substring(0,1).toUpperCase()),
                ),
              ),
            ],
          ),
        )
      ],
      elevation: 0,
      backgroundColor: colorFondoChat,
      leading: InkWell(
        onTap: () async {
          if(_one != 0){
            viewAppBar = true;
            setState(() {
              _one = 0;
            });
          }else{
            await SharedPrefe().setIntValue('openTask', 0);
            Navigator.of(context).pop();
          }
        },
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

  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  ItemScrollController _scrollController = ItemScrollController();

  Widget _mensajes(){
    return tarea == null ? Container() : Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: tareasColeccion.where("idTarea", isEqualTo: tarea.id.toString()).snapshots(),
        builder: (context,snapshot){
          if (snapshot.data == null){
            return Container(
              height: alto * 0.9,
              width: ancho,
              child: Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),),
            );
          }
          if(chatTarea != null){
            chatTarea.mensajes = snapshot.data.docs[0].data()["mensajes"];
          }

          return chatTarea != null ?

          ScrollablePositionedList.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: chatTarea.mensajes.length,
            reverse: true,
            itemPositionsListener: itemPositionsListener,
            itemScrollController: _scrollController,
            itemBuilder: (context, index){
              bool izq = false;
              int pos = chatTarea.mensajes.length - index - 1;
              if(chatTarea.mensajes['$pos']['from'] != idMyUser){
                izq = true;
              }
              Usuario userFrom;
              for(int x = 0; x < listUser.length; x++){
                if(chatTarea.mensajes['$pos']['from'] == listUser[x].id.toString()){
                  userFrom = listUser[x];
                  x = listUser.length;
                }
              }

              String dateStr = '';
              if(chatTarea.mensajes['$pos'] != null && chatTarea.mensajes['$pos']['fecha'] != null && chatTarea.mensajes['$pos']['hora'] != null){
                DateTime dateS = DateTime.parse('${chatTarea.mensajes['$pos']['fecha']} ${chatTarea.mensajes['$pos']['hora']}');
                String horario = 'am';
                if(dateS.hour > 11) {horario = 'pm'; }
                String d = dateS.day.toString().length > 1 ? dateS.day.toString() : '0${dateS.day}';
                String m = dateS.month.toString().length > 1 ? dateS.month.toString() : '0${dateS.month}';
                String h = dateS.hour.toString().length > 1 ? dateS.hour.toString() : '0${dateS.hour}';
                String min = dateS.minute.toString().length > 1 ? dateS.minute.toString() : '0${dateS.minute}';

                dateStr = '$d/$m/${dateS.year} $h:$min $horario';
              }

              bool isChatExito = false;
              if(widget.isChat != null && widget.isChat){
                if(chatTarea.mensajes['$pos']['texto'] == widget.chat['info']['texto'] &&
                    chatTarea.mensajes['$pos']['fecha'] == widget.chat['info']['fecha']
                    && chatTarea.mensajes['$pos']['hora'] == widget.chat['info']['hora']
                ){
                  isChatExito = true;
                }
              }
              return isChatExito ?
             Stack(
               children: [
                 _cardSMS(Colors.red,'${chatTarea.mensajes['$pos']['texto']}', dateStr,izq,userFrom, false),
                 AnimatedOpacity(
                   opacity: _visible ? 1.0 : 0.0,
                   duration: Duration(milliseconds: 400),
                   child: Card(
                     color: WalkieTaskColors.color_FFF5B3,
                     child: _cardSMS(Colors.red,'${chatTarea.mensajes['$pos']['texto']}', dateStr,izq,userFrom, true),
                   ),
                 ),
               ],
             )
                    :
                _cardSMS(Colors.red,'${chatTarea.mensajes['$pos']['texto']}', dateStr,izq,userFrom, false);
            },
          ) :
          Container();
        }
      ),
    );
  }

  Future<void> goToSms(Map<String,dynamic> listChat) async {
    try{
    await Future.delayed(Duration(seconds: 3));
    int pos = 0; int pos2 = 1;
    for(int x = listChat.length - 1; x >= 0; x--){
      if(listChat['$x']['texto'] == widget.chat['info']['texto'] && listChat['$x']['fecha'] == widget.chat['info']['fecha'] && listChat['$x']['hora'] == widget.chat['info']['hora']){
        pos = pos2;
      }else{
        pos2++;
      }
    }
    int sum = 0; int sumT = 0;
    for(int x = listChat.length; x > 0; x = x - 5){
      if(x >= pos && pos >= (x - 5)){
        sumT = sum; x = 0;
      }else{
        sum = sum + 5;
      }
    }
    pos = pos == 0 ? 0 : pos - 1;
    _scrollController.scrollTo(index: pos , duration: Duration(seconds: 1),);
    }catch(e){
      print('Error en goToSms');
    }
    await Future.delayed(Duration(seconds: 1));
    _visible = true;
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    _visible = false;
    setState(() {});
  }

  Widget _cardSMS(Color colorCard, String texto, String dateSrt,bool lateralDer,Usuario userFrom, bool opa){
    Image imagenAvatar = lateralDer ? null : avatarUser;
    String initialName = '';
    if(userFrom != null && userFrom.avatar_100 != null && userFrom.avatar_100 != ''){
      imagenAvatar = Image.network(userFrom.avatar_100);
    }else{
      initialName = userFrom.name.isEmpty ? '' : userFrom.name.substring(0,1).toUpperCase();
    }

    TextStyle style = WalkieTaskStyles().stylePrimary(size: alto * 0.016);

    return Container(
      margin: lateralDer ? EdgeInsets.only(right: ancho * 0.2) : EdgeInsets.only(left: ancho * 0.2),
      //height: MediaQuery.of(context).size.height * 0.05,
      child: Card(
        color: opa ? WalkieTaskColors.color_FFF5B3 : lateralDer ? Colors.white : colorfondotext,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Column(
            crossAxisAlignment: lateralDer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  lateralDer ? Container(
                    child: imagenAvatar != null ? CircleAvatar(
                      radius: alto * 0.025,
                      backgroundImage: imagenAvatar.image,
                    ) :
                    avatarWidget(alto: alto, radius:  0.025, text: initialName),
                  ) : Container(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                      child: Text(texto,
                        style: WalkieTaskStyles().stylePrimary(size: alto * 0.018,color: WalkieTaskColors.color_555555,fontWeight: FontWeight.bold, spacing: 1)
                        ,textAlign: TextAlign.left,),
                    ),
                  ),
                  !lateralDer ? Container(
                    child: CircleAvatar(
                      radius: alto * 0.025,
                      backgroundImage: imagenAvatar.image,
                    ),
                  ) : Container(),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: alto * 0.01),
                child: Text(dateSrt,style: style,),
              )
            ],
          ),
        ),
      ),
    );
  }

  String textChatSend = '';
  bool buttonSend = false;
  Widget _textFieldSend(){

    var styleBorder = const OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: const BorderRadius.all(const Radius.circular(15.0),),
    );

    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: ancho * 0.02,right: ancho * 0.02,top: alto * 0.01, bottom: alto * 0.01),
              child: TextField(
                controller: _controllerChatSms,
                maxLines: null,
                onTap: (){
                  setState(() {
                    buttonSend = true;
                  });
                },
                onChanged: (text){
                  buttonSend = textChatSend.isNotEmpty;
                  textChatSend = text;
                  setState(() {});
                },
                onSubmitted: (text){
                  buttonSend = textChatSend.isNotEmpty;
                  setState(() {});
                },
                style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D,spacing: 1,fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.sentences,
                decoration: new InputDecoration(
                  focusedBorder: styleBorder,
                  enabledBorder: styleBorder,
                  border: styleBorder,
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding:EdgeInsets.symmetric(horizontal: ancho * 0.05, vertical: alto * 0.013)
                ),
              ),
            ),
          ),
          // buttonSend ?
          Container(
            child: IconButton(
              icon: Icon(Icons.send,color: WalkieTaskColors.color_4D9DFA,),
              onPressed: () async {
                if(textChatSend.isNotEmpty){

                  DateTime now = DateTime.now();
                  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                  String formattedHours = DateFormat('kk:mm:ss').format(now);

                  ChatMessenger mensaje = new ChatMessenger(
                      fecha: formattedDate,
                      hora: formattedHours,
                      texto: textChatSend,
                      from: idMyUser
                  );

                  int pos = chatTarea.mensajes.length;
                  chatTarea.mensajes[pos.toString()] = mensaje.toJson();

                  bool res = await tareaFB.agregarMensaje(chatTarea.id,chatTarea.mensajes);
                  if(res){
                    try{
                      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                    }catch(e){
                      print('');
                    }

                    String sms = textChatSend;
                    textChatSend = '';
                    _controllerChatSms.text = '';
                    buttonSend = false;
                    setState(() {});
                    try {
                      int idSend = 0;
                      if (idMyUser != tarea.user_id.toString()) {
                        idSend = tarea.user_id;
                      } else {
                        if (idMyUser != tarea.user_responsability_id.toString()) {
                          idSend = tarea.user_responsability_id;
                        }
                      }
                      if (idSend != 0) {
                        //ENVIAR NOTIFICACION PUSH
                        try{
                          Usuario userSendNoti = await DatabaseProvider.db.getCodeIdUser(idSend.toString());
                          if (userSendNoti.fcmToken != null && userSendNoti.fcmToken.isNotEmpty) {
                            await HttpPushNotifications().httpSendMessagero(userSendNoti.fcmToken, tarea.id.toString(), description: sms,);
                            tarea.updated_at = DateTime.now().toString();
                            await DatabaseProvider.db.updateTask(tarea);
                            updateData.actualizarListaRecibidos(blocTaskSend, null);
                            updateData.actualizarListaEnviados(blocTaskSend, null);
                          }
                        }catch(e){
                          print(e.toString());
                        }
                        //ENVIAR CHAT A BITACORA
                        try{
                          Map<String,dynamic> body = {
                            "user_id" : idSend.toString(),
                            "document_id" : tarea.id.toString(),
                            "message" : sms,
                            'type' : 'smstask',
                            'created_at' : '$formattedDate $formattedHours'
                          };
                          await conexionHttp().httpBinacleSaveChat(body);
                        }catch(e){
                          print(e.toString());
                        }
                      }
                    }catch(e){
                      print(e.toString());
                    }
                  }
                }
              },
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
        if(widget.listaCasosRes[x].id == tarea.project_id){
          caso = widget.listaCasosRes[x].name;
        }
      }
    }
    bool viewImage = false;
    if(tarea != null && tarea.url_attachment != null && tarea.url_attachment.isNotEmpty){
      adjunto = tarea.url_attachment.replaceAll('%', '/');
      adjunto = adjunto.split('/').last;
      int pos = adjunto.indexOf('U$idMyUser');
      adjunto = adjunto.substring(pos + 3, adjunto.length);
      String format = adjunto.split('.').last;
      if(format == 'png' || format == 'jpg' || format == 'jpeg'){
        viewImage = true;
      }
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
      child: SingleChildScrollView(
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
                      style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C),
                    ),
                  ),
                  SizedBox(width: ancho * 0.02,),
                  tarea.url_audio != '' ?
                  InkWell(
                    child: Container(
                        child: Center(
                          child: CircleAvatar(
                            child: reproduciendo ? Icon(Icons.stop ,size: alto * 0.03,) : Icon(Icons.volume_up,size: alto * 0.03,),
                            foregroundColor: reproduciendo ? WalkieTaskColors.color_E07676 : WalkieTaskColors.color_969696,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        width: ancho * 0.07,
                        height: ancho * 0.07,
                        padding: const EdgeInsets.all(2.0), // borde width
                        decoration: new BoxDecoration(
                          color: reproduciendo ? WalkieTaskColors.color_E07676 : WalkieTaskColors.color_969696, // border color
                          shape: BoxShape.circle,
                        )
                    ),
                    onTap: (){
                      if(reproduciendo){
                        if(audioPlayer != null){
                          audioPlayer.stop();
                        }
                      }else{
                        audioPlayer.play(tarea.url_audio);
                      }

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
                        width: ancho * 0.07,
                        height: ancho * 0.07,
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
              margin: EdgeInsets.only(top:alto * 0.015,bottom: alto * 0.01),
              child: Text(descripcion,style: WalkieTaskStyles().stylePrimary(
                size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C,spacing: 0.5
              )),
            ) : Container(),
            //caso
            !verDetalle && caso != '' ?
            Container(
              margin: EdgeInsets.only(bottom: alto * 0.02),
              width: ancho,
              child: Text('${translate(context: context, text: 'projects').substring(0,translate(context: context, text: 'projects').length - 1)}: $caso',style: WalkieTaskStyles().styleHelveticaNeueBold(
                  size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C,spacing: 0.5
              )),
            ) : Container(),
            //Adjunto
            SizedBox(height: alto * 0.01,),
            Container(
              width: ancho,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  (!verDetalle && adjunto != '') ? Icon(Icons.attach_file,size: alto * 0.02,) : Container(),
                  Expanded(
                    child: (!verDetalle && adjunto != '') ?
                    GestureDetector(
                      child: Text(adjunto,style: WalkieTaskStyles().stylePrimary(
                          size: alto * 0.018, color: WalkieTaskColors.color_969696, spacing: 0.5,
                          fontWeight: FontWeight.bold
                      )),
                      onTap: () async {
                        if(!viewImage){
                          downloadFile(
                            url: tarea.url_attachment,
                            idMyUser: idMyUser,
                            contextHome: context
                          );
                        }else {
                          viewAppBar = false;
                          _one = -alto;
                          _oneFixed = -alto;
                          _top = true;
                          setState(() {});
                          _toggleTop();
                        }
                      },
                    ) : Container(),
                  ),
                  Container(
                    width: ancho * 0.1,
                    height: alto * 0.05,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: InkWell(
                          child: verDetalle ? Image.asset('assets/image/icon_open_option.png',color: Colors.grey,) : Image.asset('assets/image/icon_open_option_up.png',color: Colors.grey,),
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
      ),
    );
  }

  Widget _editTarea(BuildContext context){

    var appLanguage = Provider.of<LanguageProvider>(context);


    return Container(
      margin: EdgeInsets.only(left: ancho * 0.02,right: ancho * 0.02,top: alto * 0.01),
      padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01,left: ancho * 0.05, right: ancho * 0.05),
      width: ancho,
      decoration: new BoxDecoration(
        color: colorfondoDetalle,
        border: Border.all(width: 1,color: colorBordeOpc),
        borderRadius: BorderRadius.all(Radius.circular(10),),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: ancho,
              child: Text(translate(context: context, text: 'editTask'),
                style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C),
              ),
            ),
            SizedBox(height: alto * 0.025,),
            Container(
              width: ancho,
              child: Text('${translate(context: context, text: 'title')}:',
                style: WalkieTaskStyles().stylePrimary(size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
              ),
            ),
            SizedBox(height: alto * 0.008,),
            Container(
              width: ancho,
              child: TextFildGeneric(
                labelStyle: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
                initialValue: null,
                onChanged: (String value) {},
                sizeW: ancho,
                sizeH: alto,
                sizeHeight: alto * 0.04,
                textEditingController: _controllerTitle,
                borderColor: WalkieTaskColors.color_E2E2E2,
                sizeBorder: 1.8,
              ),
            ),
            SizedBox(height: alto * 0.02,),
            Container(
              width: ancho,
              child: Text(translate(context: context, text: 'description'),
                style: WalkieTaskStyles().stylePrimary(size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
              ),
            ),
            SizedBox(height: alto * 0.008,),
            Container(
              width: ancho,
              child: TextFildGeneric(
                labelStyle: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
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
                padding: EdgeInsets.only(left: 5, top: alto * 0.01, right: 5, bottom: alto * 0.01),
              ),
            ),
            SizedBox(height: alto * 0.03,),
            Container(
              width: ancho,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: ancho * 0.03),
                    child: Text(translate(context: context, text: 'date'),textAlign: TextAlign.right,
                      style: WalkieTaskStyles().stylePrimary(size: alto * 0.022, color: WalkieTaskColors.color_3C3C3C, spacing: 1),),
                  ),
                  Container(
                    width: ancho * 0.5,
                    height: alto * 0.04,
                    child: InkWell(
                      onTap: () async {
                        DateTime newDateTime = await showDatePicker(
                          context: context,
                          initialDate: new DateTime.now(),
                          firstDate: new DateTime(2018),
                          lastDate: new DateTime(2025),
                          locale: appLanguage.appLocal,
                        );
                        if (newDateTime != null) {
                          Duration dif = newDateTime.difference(DateTime.now());
                          if(dif.inDays >= 0){
                            setState(() => fechaTask = newDateTime);
                          }else{
                            showAlert(translate(context: context, text: 'dateMust'),Colors.red[400]);
                          }
                        }
                      },
                      child: Container(
                        decoration: new BoxDecoration(
                          border: Border.all(width: 1.2,color: WalkieTaskColors.color_E2E2E2),
                          borderRadius: BorderRadius.all(Radius.circular(5.0),),
                        ),
                        child: fechaTask != null ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                child: Text('${fechaTask.day}-${fechaTask.month}-${fechaTask.year}',
                                  style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_3C3C3C, spacing: 1),
                                  textAlign: TextAlign.center,
                                ),
                            ),
                            InkWell(
                              child: Icon(Icons.clear,size: alto * 0.03,),
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
                  loadSaveEdit ?
                  Container(
                    width: alto * 0.04,
                    height: alto * 0.04,
                    child: Center(child: CircularProgressIndicator(),),
                  ) :
                  RoundedButton(
                    borderColor: WalkieTaskColors.primary,
                    width: ancho * 0.2,
                    height: alto * 0.04,
                    radius: 5.0,
                    title: translate(context: context, text: 'ok'),
                    textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.035, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1.5),
                    backgroundColor: WalkieTaskColors.primary,
                    onPressed: () => _saveEditTask(),
                  ),
                  SizedBox(width: ancho * 0.04,),
                  RoundedButton(
                    borderColor: WalkieTaskColors.white,
                    height: alto * 0.04,
                    radius: 5.0,
                    title: translate(context: context, text: 'cancel'),
                    textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.04, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 1.5),
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
      ),
    );
  }

  bool loadSaveEdit = false;
  Future<void> _saveEditTask() async {
    setState(() {
      loadSaveEdit = true;
    });
    try{
      conexionHttp connectionHttp = new conexionHttp();
      Map<String,dynamic> body = {
        'name' : '${_controllerTitle.text}',
        //'deadline' : fechaTask.toString(),
        //'description' : '${_controllerDescription.text}'
      };
      if(_controllerDescription.text.isNotEmpty){
        body['description'] = '${_controllerDescription.text}';
      }
      if(fechaTask != null){
        body['deadline'] = fechaTask.toString();
      }


      var response = await connectionHttp.httpUpdateTask(body, tarea.id);
      var value = jsonDecode(response.body);
      if(response.statusCode == 200){
        showAlert('Tarea modificada con exito!',WalkieTaskColors.color_89BD7D);
        if(tarea.project_id != 0){
          await DatabaseProvider.db.updateDateCase(tarea.project_id.toString());
        }
        updateData.actualizarListaRecibidos(blocTaskSend, null);
        updateData.actualizarListaEnviados(blocTaskSend, null);
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
    setState(() {
      loadSaveEdit = false;
    });
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
    tarea = await DatabaseProvider.db.getCodeIdTask(tarea.id.toString());
    setState(() {});
  }

  Future<void> listenerAudio() async {
    audioPlayer.onAudioPositionChanged.listen((Duration  p){
      print('Current position: $p');
    });
    AudioPlayerState oldState = AudioPlayerState.COMPLETED;
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      print('Current player state: $s');
      if(AudioPlayerState.COMPLETED == s){
        setState(() {
          reproduciendo = false;
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
        if(mounted){
          setState(() {
            reproduciendo = false;
          });
        }
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

  bool _top = false;
  Duration _duration = Duration(milliseconds: 5);
  double _one = 0;
  double _oneFixed = 0;
  void _toggleTop() {
    Timer.periodic(_duration, (timer) {
      if (_top) _one += 20;

      if (_one >= 0) {
        _one = -0.1;
        timer.cancel();
      }
      if (_one <= _oneFixed) {
        _one = _oneFixed;
        timer.cancel();
      }
      setState(() {});
    });
  }

  Widget _myContainer() {
    return Stack(
      children: [
        Container(
          color: colorFondoChat,
          height: alto,
          width: ancho,
          child: Center(
            child: Container(
              height: alto * 0.1,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset('assets/image/loading2.gif').image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Container(
          //color: colorFondoChat,
          height: alto,
          width: ancho,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.network(tarea.url_attachment).image,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        // Container(
        //   width: ancho,
        //   child: FadeInImage.memoryNetwork(
        //     placeholder: kTransparentImage,
        //     image: tarea.url_attachment,
        //     fit: BoxFit.fitWidth,
        //   ),
        // ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: alto * 0.02, right: ancho * 0.08),
            child: CircleAvatar(
              backgroundColor: WalkieTaskColors.primary,
              child: InkWell(
                child: Icon(Icons.download_sharp, color: WalkieTaskColors.white,size: alto * 0.05,),
                onTap: () async{
                  try{
                    downloadFile(
                        url: tarea.url_attachment,
                        idMyUser: idMyUser,
                        contextHome: context
                    );
                  }catch(e){
                    print(e.toString());
                    showAlert('Error al descargar imagen, verifique su conexión.',WalkieTaskColors.color_89BD7D);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

}

