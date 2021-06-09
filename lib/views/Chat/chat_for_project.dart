import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Firebase/Notification/push_notifications_provider.dart';
import 'package:walkietaskv2/services/Firebase/chat_project_firebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/widgets_chat_for_project/chat_project.dart';
import 'package:walkietaskv2/views/Chat/widgets_chat_for_project/edit_project.dart';
import 'package:walkietaskv2/views/Chat/widgets_chat_for_project/task_for_users.dart';

class ChatForProject extends StatefulWidget {

  ChatForProject({
    @required this.project,
    @required this.widgetHome,
    @required this.blocCasos,
    @required this.mapIdUser,
    @required this.push,
    @required this.myUser,
    @required this.listaCasos,
    @required this.blocTaskReceived,
    @required this.blocTaskSend,
    @required this.blocAudioChangePage,
    @required this.blocIndicatorProgress,
    @required this.updateData,
  });

  final Caso project;
  final Map<String,dynamic> widgetHome;
  final BlocCasos blocCasos;
  final Map<int,Usuario> mapIdUser;
  final PushProvider push;
  final BlocTask blocTaskReceived;
  final BlocTask blocTaskSend;
  final List<Caso> listaCasos;
  final Usuario myUser;
  final BlocProgress blocAudioChangePage;
  final BlocProgress blocIndicatorProgress;
  final UpdateData updateData;

  @override
  _ChatForProjectState createState() => _ChatForProjectState();
}

class _ChatForProjectState extends State<ChatForProject> {

  final controllerPage = PageController(initialPage: 0,);

  double alto = 0;
  double ancho = 0;
  String idMyUser = '0';
  Caso project;
  Map<String,dynamic> widgetHome;
  int page = 0;
  List<Widget> _pages = [];
  List<Usuario> listUser = [];
  bool loadData = true;

  @override
  void initState() {
    super.initState();
    initialUser();
    project = widget.project;
    widgetHome = widget.widgetHome;
  }

  @override
  void dispose() {
    super.dispose();
    controllerPage.dispose();
  }

  initialUser() async {
    idMyUser = await SharedPrefe().getValue('unityIdMyUser');
    listUser = await DatabaseProvider.db.getAllUser();

    ChatTareas chatProject;
    try{
      ChatTareas chatVery = await ChatProjectFirebase().checkChat(project.id.toString());
      if(chatVery != null){
        chatProject = chatVery;
      }else{
        ChatTareas chat = new ChatTareas(
          id: '',
          idTarea: project.id.toString(),
          idUser: project.user_id.toString(),
          idFromUser: project.userprojects,
          mensajes: new Map<String,dynamic>(),
          task: project.toMap(),
        );
        ChatTareas chatTareaNew = await ChatProjectFirebase().createChat(chat);
        if(chatTareaNew != null){
          chatProject = chatTareaNew;
        }else{
          print('NO CREADO');
        }
      }
    }catch(_){}

    List<Tarea> listA = [];
    List<Tarea> listB = [];
    List<Tarea> listTask = [];

    widgetHome['cantTaskAssigned'].forEach((element) { listA.add(element); listB.add(element); });
    widgetHome['cantTaskSend'].forEach((element) { listA.add(element); listB.add(element);});

    for(int x = 0; x < listA.length; x++){
      int pos = 0;
      DateTime date1 = DateTime.parse(listA[x].updated_at);
      for(int x1 = 0; x1 < listB.length; x1++){
        DateTime date2 = DateTime.parse(listA[x1].updated_at);
        if(date2.isAfter(date1)){
          pos = x1;
        }
      }
      listTask.add(listB[pos]);
      listB.removeAt(pos);
    }

    _pages = [
      ChatProject(
        project: project,
        chatProject: chatProject,
        listUser: listUser,
        blocCasos: widget.blocCasos,
        widgetHome: widgetHome,
        listaCasos: widget.listaCasos,
        blocIndicatorProgress: widget.blocIndicatorProgress,
        blocTaskSend: widget.blocTaskSend,
        blocTaskReceived: widget.blocTaskReceived,
        updateData: widget.updateData,
      ),
      TaskForUsers(
        project: project,
        widgetHome: widgetHome,
        mapIdUser: widget.mapIdUser,
      ),
      Container(),
    ];

    loadData = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: _appBarH(),
        body: body(),
      )
    );
  }

  Widget body(){
    return Container(
      width: ancho,
      child: Column(
        children: [
          header(),
          loadData ?
          Container(
            width: ancho,
            height: alto * 0.5,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ) :
          Flexible(
            child: pageViewContainer(),
          )
        ],
      ),
    );
  }

  Widget header(){

    String cantTask = '${widgetHome['cantTaskAssigned'].length + widgetHome['cantTaskSend'].length}' ?? '';
    String cantAssigned = '${widgetHome['cantTaskAssigned'].length}' ?? '';
    cantTask = cantTask == '0' ? '' : '($cantTask)';
    cantAssigned = cantAssigned == '0' ? '' : '($cantAssigned)';

    return Container(
      width: ancho,
      child: Row(
        children: [
          Expanded(child: titleHeader(title: 'Chat',selected: page == 0, pos: 0)),
          Expanded(child: titleHeader(title: '${translate(context: context, text: 'tasks')} $cantTask',selected: page == 1, pos: 1)),
          Expanded(child: titleHeader(title: '${translate(context: context, text: 'assigned')} $cantAssigned',selected: page == 2, pos: 2)),
        ],
      ),
    );
  }

  Widget titleHeader({@required String title, @required bool selected,@required int pos}){
    return InkWell(
      child: Container(
        color: selected ? WalkieTaskColors.color_4D4D4D : WalkieTaskColors.color_B7B7B7,
        padding: EdgeInsets.all(alto * 0.015),
        child: Text(
          title,
          style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02,color: !selected ? WalkieTaskColors.color_4D4D4D : WalkieTaskColors.color_B7B7B7),
          textAlign: TextAlign.center,
        ),
      ),
      onTap: () => _goToPage(pos),
    );
  }

  void _goToPage(int go) {
    controllerPage.animateToPage(go,duration: const Duration(milliseconds: 1),
      curve: Curves.linear,
    );
  }

  Widget pageViewContainer(){
    return PageView(
      controller: controllerPage,
      onPageChanged: (int index) async{
        page = index;
        setState(() {});
      },
      children: _pages,
    );
  }

  Widget _appBarH(){
    String nombreUser = project.name ?? '';
    return AppBar(
      leading: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
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
      actions: <Widget>[
        Container(
          width: ancho,
          child: Row(
            children: <Widget>[
              Container( width: ancho * 0.1, ),
              Expanded(
                  child: Text('$nombreUser',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_3C3C3C),textAlign: TextAlign.center,),
              ),
              Center(
                child: InkWell(
                  child: Container(
                    margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.02),
                    child: Icon(Icons.info_outline, size: alto * 0.03,color: WalkieTaskColors.color_4EA0F0,),
                  ),
                  onTap: (){
                    Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new EditProject(
                          widgetHome: widgetHome,
                          project: project,
                          blocCasos: widget.blocCasos,
                        )));
                  },
                ),
              ),
            ],
          ),
        )
      ],
      elevation: 0,
      backgroundColor: colorFondoChat,
    );
  }
}

