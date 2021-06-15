import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Chat/ChatMessenger.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Firebase/Notification/http_notifications.dart';
import 'package:walkietaskv2/services/Firebase/chat_project_firebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/widgets_chat_for_project/selected_users.dart';

class ChatProject extends StatefulWidget {

  ChatProject({
    @required this.project,
    @required this.chatProject,
    @required this.listUser,
    @required this.blocCasos,
    @required this.widgetHome,
    @required this.listaCasos,
    @required this.blocIndicatorProgress,
    @required this.blocTaskSend,
    @required this.blocTaskReceived,
    @required this.updateData,
  });
  final Caso project;
  final ChatTareas chatProject;
  final List<Usuario> listUser;
  final BlocCasos blocCasos;
  final Map<String,dynamic> widgetHome;
  final List<Caso> listaCasos;
  final BlocProgress blocIndicatorProgress;
  final BlocTask blocTaskReceived;
  final BlocTask blocTaskSend;
  final UpdateData updateData;

  @override
  _ChatProjectState createState() => _ChatProjectState();
}

class _ChatProjectState extends State<ChatProject> {

  CollectionReference projectCollection = FirebaseFirestore.instance.collection('Project');
  final ScrollController listScrollController = new ScrollController();

  double alto = 0;
  double ancho = 0;
  String idMyUser = '0';
  Caso project;
  TextEditingController _controllerChatSms = TextEditingController();
  ChatTareas chatProject;
  List<Usuario> listUser;
  Image avatarUser;

  bool viewOptionCreateTask = false;

  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  ItemScrollController _scrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    project = widget.project;
    chatProject = widget.chatProject;
    listUser = widget.listUser;
    initialUser();
  }

  initialUser() async {
    idMyUser = await SharedPrefe().getValue('unityIdMyUser');
    avatarUser = await getPhotoUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorChat,
      body: Stack(
        children: [
          messages(),
          Positioned.fill(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: _textFieldSend(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFieldSend(){

    var styleBorder = const OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: const BorderRadius.all(const Radius.circular(15.0),),
    );

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          !viewOptionCreateTask ? Container() :
          Container(
            width: ancho,
            margin: EdgeInsets.only(right: ancho * 0.5),
            padding: EdgeInsets.only(left: ancho * 0.01,bottom: alto * 0.015, top: alto * 0.015),
            decoration: BoxDecoration(
              color: colorFondoSend,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(0.0),
                topLeft: Radius.circular(0.0),
                bottomLeft: Radius.circular(0.0)
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                containerOption(1),
                SizedBox(height: alto * 0.02,),
                containerOption(2)
              ],
            ),
          ),
          Container(
            color: colorFondoSend,
            constraints: BoxConstraints(minHeight: alto * 0.07,maxHeight: alto * 0.15),
            child: Row(
              children: <Widget>[
                Container(
                  child: IconButton(
                    icon: Icon(Icons.add_circle_outline,color: WalkieTaskColors.color_4D9DFA,),
                    onPressed: (){
                      setState(() {
                        viewOptionCreateTask = !viewOptionCreateTask;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: ancho * 0.02,right: ancho * 0.02,top: alto * 0.01, bottom: alto * 0.01),
                    child: TextField(
                      controller: _controllerChatSms,
                      maxLines: null,
                      onTap: (){},
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
                Container(
                  child: IconButton(
                    icon: Icon(Icons.send,color: WalkieTaskColors.color_4D9DFA,),
                    onPressed: () => sendMessage(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget containerOption(int type){
    IconData icon = Icons.title;
    String title = translate(context: context, text: 'sendTextAssignment');
    if(type == 2){
      icon = Icons.mic;
      title = translate(context: context, text: 'submitAudioAssignment');
    }
    return Container(
      width: ancho,
      child: Row(
        children: [
          Icon(icon,color: WalkieTaskColors.primary,size: alto * 0.03,),
          SizedBox(width: ancho * 0.02,),
          Expanded(
            child: InkWell(
              child: Text(title,style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018,spacing: 0.4),),
              onTap: () => containerOptionOnTap(type),
            ),
          ),
        ],
      ),
    );
  }

  void containerOptionOnTap(int type){
    viewOptionCreateTask = false;
    setState(() {});
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) =>
        new SelectedUserSendTask(
          widgetHome: widget.widgetHome,
          isAudio: type == 2,
          listaCasos: widget.listaCasos,
          blocIndicatorProgress: widget.blocIndicatorProgress,
          blocTaskReceived: widget.blocTaskReceived,
          blocTaskSend: widget.blocTaskSend,
          updateData: widget.updateData,
        )));
  }

  Future<void> sendMessage() async {
    if(_controllerChatSms.text.isNotEmpty){

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedHours = DateFormat('kk:mm:ss').format(now);

      ChatMessenger mensaje = new ChatMessenger(
          fecha: formattedDate,
          hora: formattedHours,
          texto: _controllerChatSms.text,
          from: idMyUser
      );

      int pos = chatProject.mensajes.length;
      chatProject.mensajes[pos.toString()] = mensaje.toJson();

      bool res = await ChatProjectFirebase().addMessage(chatProject.id,chatProject.mensajes);
      if(res){
        try{
          listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        }catch(e){
          print('');
        }

        String sms = _controllerChatSms.text;
        _controllerChatSms.text = '';
        setState(() {});

        try {
          List<String> usersShowNotification = project.userprojects.split('|');
          for(int x = 0; x < usersShowNotification.length; x++){
            if(usersShowNotification[x] != idMyUser && usersShowNotification[x].isNotEmpty){
              //ENVIAR NOTIFICACION PUSH A CADA USUARIO
              try{
                Usuario userSendNoti = await DatabaseProvider.db.getCodeIdUser(usersShowNotification[x]);
                if (userSendNoti.fcmToken != null && userSendNoti.fcmToken.isNotEmpty) {
                  await HttpPushNotifications().httpSendMessagero(userSendNoti.fcmToken, project.id.toString(), description: sms,isProject: true);
                  await DatabaseProvider.db.updateDateCase(project.id.toString());
                  UpdateData().actualizarCasos(widget.blocCasos);
                }
              }catch(e){
                print(e.toString());
              }
            }
          }

          //ENVIAR CHAT DE PROYECTO A BITACORA
          // try{
          //   Map<String,dynamic> body = {
          //     "user_id" : idSend.toString(),
          //     "document_id" : tarea.id.toString(),
          //     "message" : sms,
          //     'type' : 'smstask',
          //     'created_at' : '$formattedDate $formattedHours'
          //   };
          //   await conexionHttp().httpBinacleSaveChat(body);
          // }catch(e){
          //   print(e.toString());
          // }
        }catch(e){
          print(e.toString());
        }
      }
    }
  }

  Widget messages(){
    return project == null ? Container() : Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: projectCollection.where("idTarea", isEqualTo: project.id.toString()).snapshots(),
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
            if(chatProject != null){
              chatProject.mensajes = snapshot.data.docs[0].data()["mensajes"];
            }

            return chatProject == null ? Container() :
            ScrollablePositionedList.builder(
              padding: EdgeInsets.only(left: 10.0,top: 10.0,right: 10.0,bottom: alto <= 600 ? alto * 0.1 : alto * 0.08),
              itemCount: chatProject.mensajes.length,
              reverse: true,
              itemPositionsListener: itemPositionsListener,
              itemScrollController: _scrollController,
              itemBuilder: (context, index){
                bool izq = false;
                int pos = chatProject.mensajes.length - index - 1;
                if(chatProject.mensajes['$pos']['from'] != idMyUser){
                  izq = true;
                }
                Usuario userFrom;
                for(int x = 0; x < listUser.length; x++){
                  if(chatProject.mensajes['$pos']['from'] == listUser[x].id.toString()){
                    userFrom = listUser[x];
                    x = listUser.length;
                  }
                }

                String dateStr = '';
                if(chatProject.mensajes['$pos'] != null && chatProject.mensajes['$pos']['fecha'] != null && chatProject.mensajes['$pos']['hora'] != null){
                  DateTime dateS = DateTime.parse('${chatProject.mensajes['$pos']['fecha']} ${chatProject.mensajes['$pos']['hora']}');
                  String horario = 'am';
                  if(dateS.hour > 11) {horario = 'pm'; }
                  String d = dateS.day.toString().length > 1 ? dateS.day.toString() : '0${dateS.day}';
                  String m = dateS.month.toString().length > 1 ? dateS.month.toString() : '0${dateS.month}';
                  String h = dateS.hour.toString().length > 1 ? dateS.hour.toString() : '0${dateS.hour}';
                  String min = dateS.minute.toString().length > 1 ? dateS.minute.toString() : '0${dateS.minute}';

                  dateStr = '$d/$m/${dateS.year} $h:$min $horario';
                }

                return _cardSMS(Colors.red,'${chatProject.mensajes['$pos']['texto']}', dateStr,izq,userFrom, false);
              },
            );
          }
      ),
    );
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
                    child: imagenAvatar == null ?
                    avatarWidget(alto: alto, radius: 0.025, text: initialName.isEmpty ? '' : initialName.substring(0,1).toUpperCase())
                        :
                    CircleAvatar(
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

}
