import 'dart:async';

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
import 'package:walkietaskv2/services/Firebase/chatTareasFirebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatForTarea extends StatefulWidget {

  ChatForTarea({this.tareaRes,this.listaCasosRes, this.blocTaskSend});

  final Tarea tareaRes;
  final List<Caso> listaCasosRes;
  final BlocTask blocTaskSend;

  @override
  _ChatForTareaState createState() => _ChatForTareaState();
}

class Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset.zero, size.bottomRight(Offset.zero), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // bad, but okay for example
    return true;
  }
}

enum StatusChat { Creando , Creado , Error }

class _ChatForTareaState extends State<ChatForTarea> {

  Tarea tarea;
  ChatTareas chatTarea;
  StatusChat statusChat = StatusChat.Creando;
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

  double alto = 0;
  double ancho = 0;

  BlocTask blocTaskSend;

  StreamSubscription streamSubscriptionTaskSend;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    blocTaskSend = widget.blocTaskSend;

    audioPlayer = new AudioPlayer();
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    controllerSend = new TextEditingController();
    tarea = widget.tareaRes;
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
    streamSubscriptionTaskSend.cancel();
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
      title: Container(
        width: ancho,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: imagenUser!= null ?
              Container(
                padding: const EdgeInsets.all(3.0), // borde width
                decoration: new BoxDecoration(
                  color: bordeCirculeAvatar, // border color
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: alto * 0.03,
                  backgroundImage: imagenUser.image,
                  //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                ),
              ) : Container(),
            ),
            Expanded(
                flex: 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('$nombreUser',style: TextStyle(fontFamily: 'helveticaneue2',fontSize: 16,color: colortitulo1),textAlign: TextAlign.center,),
                    Text('$correoUSer',style: estiloLetras(14,colortitulo2),textAlign: TextAlign.left,)
                  ],
                )
            )
          ],
        ),
      ),
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
    if(tarea != null && tarea.url_attachment != null){
      adjunto = tarea.url_attachment.replaceAll('https://appunity.s3-us-east-2.amazonaws.com/attached%', '');
    }
    return Container(
      margin: EdgeInsets.only(left: ancho * 0.02,right: ancho * 0.02,top: alto * 0.01),
      padding: EdgeInsets.only(left: ancho * 0.07,right: ancho * 0.07),
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
            margin: EdgeInsets.only(top: alto * 0.02,bottom: alto * 0.01),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 10,
                  child: Text(tarea.name,style: TextStyle(
                    color: coloraudioDetwalle,fontSize: alto * 0.03,fontWeight: FontWeight.bold
                  ),textAlign: TextAlign.left,),
                ),
                tarea.url_audio != '' ? Expanded(
                  flex: 3,
                  child:  InkWell(
                    child: Container(
                        child: new CircleAvatar(
                          child: Icon(Icons.volume_up,size: alto * 0.05,),
                          foregroundColor: colorfuenteDetwalle,
                          backgroundColor: Colors.white,
                        ),
                        width: ancho * 0.12,
                        height: ancho * 0.12,
                        padding: const EdgeInsets.all(2.0), // borde width
                        decoration: new BoxDecoration(
                          color: colorfuenteDetwalle, // border color
                          shape: BoxShape.circle,
                        )
                    ),
                    onTap: (){
                      audioPlayer.play(tarea.url_audio);
                    },
                  ),
                ) : Container(),
              ],
            ),
          ),
          //descripcion
          !verDetalle && descripcion != '' ?
          Container(
            margin: EdgeInsets.only(top:alto * 0.01,bottom: alto * 0.02),
            child: Text(descripcion,style: TextStyle(
                color: coloraudioDetwalle,fontSize: alto * 0.022,fontWeight: FontWeight.bold
            ),textAlign: TextAlign.left,),
          ) : Container(),
          //caso
          !verDetalle && caso != '' ?
          Container(
            margin: EdgeInsets.only(bottom: alto * 0.02),
            width: ancho,
            child: Text('Caso: $caso',style: TextStyle(
                color: coloraudioDetwalle,fontSize: alto * 0.022,fontWeight: FontWeight.bold
            ),textAlign: TextAlign.right,),
          ) : Container(),
          //Adjunto
          !verDetalle && adjunto != '' ?
              InkWell(
                child: Container(
                  width: ancho,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(Icons.attach_file,size: alto * 0.02,),
                      Text(adjunto,style: TextStyle(
                          color: coloraudioDetwalle,fontSize: alto * 0.015,fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.right,),
                    ],
                  ),
                ),
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
              )
           : Container(),
          //botton cerrar/abrir
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
          SizedBox(height: alto * 0.01,),
        ],
      ),
    );
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

}
