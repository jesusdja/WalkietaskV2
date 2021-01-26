import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
import 'package:walkietaskv2/services/Firebase/Notification/http_notifications.dart';
import 'package:walkietaskv2/services/Firebase/chatTareasFirebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
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
  DateTime fechaTask;
  DateTime fechaTaskOld;
  TextEditingController _controllerChatSms;
  TextEditingController _controllerTitle;
  TextEditingController _controllerDescription;

  UpdateData updateData = new UpdateData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blocTaskSend = widget.blocTaskSend;

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
    listUser = await DatabaseProvider.db.getAllUser();

    int idSearch;
    if(tarea.user_id.toString() == idMyUser){
      idSearch = tarea.user_responsability_id;
    }else{
      idSearch = tarea.user_id;
    }

    if(tarea.user_responsability_id != null){
      usuarioResponsable = await DatabaseProvider.db.getCodeIdUser(idSearch.toString());
    }
    setState(() {});
  }

  inicializar() async {
    try{
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
        appBar: _appBarH(),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: alto * 0.07, top: alto * 0.1),
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
                      Text('$correoUSer',style: WalkieTaskStyles().stylePrimary(size: alto * 0.017, color: WalkieTaskColors.color_969696,spacing: 1.2,fontWeight: FontWeight.bold))
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

          ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: chatTarea.mensajes.length,
            reverse: true,
            controller: listScrollController,
            itemBuilder: (context, index){
              bool izq = false;
              int pos = chatTarea.mensajes.length - index - 1;
              if(chatTarea.mensajes['$pos']['from'] != idMyUser){
                izq = true;
              }
              Usuario userFrom;
              for(int x = 0; x < listUser.length; x++){
                if(chatTarea.mensajes['$pos']['from'] == listUser[x].id){
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

                dateStr = '$d/$m/${dateS.year} $h/$min $horario';
              }

              return _cardSMS(Colors.red,'${chatTarea.mensajes['$pos']['texto']}', dateStr,izq,userFrom);
            },
          ) :
          Container();
        }
      ),
    );
  }

  Widget _cardSMS(Color colorCard, String texto, String dateSrt,bool lateralDer,Usuario userFrom){

    Image imagenAvatar = Image.network('$avatarImage');
    if(userFrom != null && userFrom.avatar != null && userFrom.avatar != ''){
      imagenAvatar = Image.network('$directorioImage${userFrom.avatar}');
    }

    TextStyle style = WalkieTaskStyles().stylePrimary(size: alto * 0.016);

    return Container(
      margin: lateralDer ? EdgeInsets.only(right: ancho * 0.2) : EdgeInsets.only(left: ancho * 0.2),
      //height: MediaQuery.of(context).size.height * 0.05,
      child: Card(
        color: lateralDer ? Colors.white : colorfondotext,
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
                    child: CircleAvatar(
                      radius: alto * 0.025,
                      backgroundImage: imagenAvatar.image,
                    ),
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

/*
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
                    Usuario userSendNoti = await DatabaseProvider.db.getCodeIdUser(idSend.toString());
                    if (userSendNoti.fcmToken != null && userSendNoti.fcmToken.isNotEmpty) {
                      var rese = await HttpPushNotifications().httpSendMessagero(userSendNoti.fcmToken, tarea.id.toString(), description: 'Este es el sms',);
                      tarea.updated_at = DateTime.now().toString();
                      await DatabaseProvider.db.updateTask(tarea);
                      updateData.actualizarListaRecibidos(blocTaskSend, null);
                      updateData.actualizarListaEnviados(blocTaskSend, null);
                    }
                  }
                }catch(e){
                  print(e.toString());
                }
*/


                if(textChatSend.isNotEmpty){

                  DateTime now = DateTime.now();
                  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                  String formattedHours = DateFormat('kk:mm').format(now);

                  ChatMessenger mensaje = new ChatMessenger(
                      fecha: formattedDate,
                      hora: formattedHours,
                      texto: textChatSend,
                      from: idMyUser
                  );

                  int pos = chatTarea.mensajes.length;
                  // Map<dynamic,dynamic> maplista = Map<String,dynamic>();
                  //   chatTarea.mensajes.forEach((key,value){
                  //     maplista[pos.toString()] = value;
                  //     pos++;
                  //   });
                  chatTarea.mensajes[pos.toString()] = mensaje.toJson();

                  // Map<dynamic,dynamic> maplista = Map<String,dynamic>();
                  // maplista['0'] = mensaje.toJson();
                  // int pos = 1;
                  // if(chatTarea.mensajes != null){
                  //   chatTarea.mensajes.forEach((key,value){
                  //     maplista[pos.toString()] = value;
                  //     pos++;
                  //   });
                  // }



                  bool res = await tareaFB.agregarMensaje(chatTarea.id,chatTarea.mensajes);
                  if(res){
                    listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                    String sms = textChatSend;
                    textChatSend = '';
                    _controllerChatSms.text = '';
                    buttonSend = false;
                    //FocusScope.of(context).requestFocus(new FocusNode());
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
                        Usuario userSendNoti = await DatabaseProvider.db.getCodeIdUser(idSend.toString());
                        if (userSendNoti.fcmToken != null && userSendNoti.fcmToken.isNotEmpty) {
                            await HttpPushNotifications().httpSendMessagero(userSendNoti.fcmToken, tarea.id.toString(), description: sms,);
                            tarea.updated_at = DateTime.now().toString();
                            await DatabaseProvider.db.updateTask(tarea);
                            updateData.actualizarListaRecibidos(blocTaskSend, null);
                            updateData.actualizarListaEnviados(blocTaskSend, null);
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
              // :
          // Container(
          //   child: Row(
          //     children: [
          //       Container(
          //         height: alto * 0.03,
          //         width: alto * 0.035,
          //         decoration: BoxDecoration(
          //           image: DecorationImage(
          //             image: ViewImage().assetsImage("assets/image/Attachment.png").image,
          //             fit: BoxFit.contain,
          //           ),
          //         ),
          //       ),
          //       //IconButton(icon: Icon(Icons.mic,color: Colors.grey,), onPressed: (){}),
          //       SizedBox(width: ancho * 0.01,),
          //       //IconButton(icon: Icon(Icons.camera_alt,color: Colors.grey,), onPressed: (){}),
          //       Container(
          //         height: alto * 0.03,
          //         width: alto * 0.035,
          //         decoration: BoxDecoration(
          //           image: DecorationImage(
          //             image: ViewImage().assetsImage("assets/image/chat_cam.png",color: Colors.black).image,
          //             fit: BoxFit.contain,
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: ancho * 0.03,),
          //     ],
          //   ),
          // )
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
                            child: Icon(Icons.volume_up,size: alto * 0.03,),
                            foregroundColor: reproduciendo ? Colors.green : WalkieTaskColors.color_969696,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        width: ancho * 0.07,
                        height: ancho * 0.07,
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
                          size: alto * 0.018, color: WalkieTaskColors.color_969696, spacing: 0.5,
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
      ),
    );
  }

  Widget _editTarea(BuildContext context){

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
              child: Text('Editar tarea',
                style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C),
              ),
            ),
            SizedBox(height: alto * 0.025,),
            Container(
              width: ancho,
              child: Text('Titulo:',
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
              child: Text('Descripción',
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
                    child: Text('Fecha',textAlign: TextAlign.right,
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
                            locale: Locale('es', 'ES'),

                        );
                        if (newDateTime != null) {
                          setState(() => fechaTask = newDateTime);
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
                    width: ancho * 0.2,
                    height: alto * 0.04,
                    child: Center(child: CircularProgressIndicator(),),
                  ) :
                  RoundedButton(
                    borderColor: WalkieTaskColors.primary,
                    width: ancho * 0.2,
                    height: alto * 0.04,
                    radius: 5.0,
                    title: 'Aceptar',
                    textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.035, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1.5),
                    backgroundColor: WalkieTaskColors.primary,
                    onPressed: () => _saveEditTask(),
                  ),
                  SizedBox(width: ancho * 0.07,),
                  RoundedButton(
                    borderColor: WalkieTaskColors.white,
                    width: ancho * 0.2,
                    height: alto * 0.04,
                    radius: 5.0,
                    title: 'Cancelar',
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
