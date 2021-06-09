import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Firebase/Notification/push_notifications_provider.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/provider/home_provider.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/format_deadline.dart';
import 'package:walkietaskv2/utils/task_sound.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/chat_for_project.dart';
import 'package:walkietaskv2/views/Tareas/Create/detalles_tareas_user.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';
import 'package:walkietaskv2/views/Home/NavigatorBotton.dart';


class CreateTask extends StatefulWidget {

  CreateTask({
    @required this.blocUserRes,
    @required this.listUserRes,
    @required this.mapIdUserRes,
    @required this.myUserRes,
    @required this.listaCasosRes,
    @required this.blocTaskReceived,
    @required this.blocTaskSend,
    @required this.blocIndicatorProgress,
    @required this.listRecibidos,
    @required this.listEnviadosRes,
    @required this.mapDataUserHome,
    @required this.updateData,
    @required this.blocAudioChangePage,
    @required this.listWidgetsHome,
    @required this.blocCasos,
    @required this.push,
  });

  final Map<int,Usuario> mapIdUserRes;
  final List<Usuario> listUserRes;
  final List<Caso> listaCasosRes;
  final List<Tarea> listEnviadosRes;
  final List<Tarea> listRecibidos;
  final Usuario myUserRes;
  final BlocUser blocUserRes;
  final BlocCasos blocCasos;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;
  final BlocProgress blocIndicatorProgress;
  final Map<int,List> mapDataUserHome;
  final UpdateData updateData;
  final BlocProgress blocAudioChangePage;
  final List<dynamic> listWidgetsHome;
  final PushProvider push;

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {

  bool iconBuscador = false;

  double alto = 0;
  double ancho = 0;
  int posPersonal = 0;

  TextStyle textStylePrimary;
  TextStyle textStylePrimaryLitle;
  TextStyle textStylePrimaryBold;
  TextStyle textStylePrimaryLitleRed;
  TextStyle textStylePrimaryLitleBold;
  TextStyle textStylePrimaryTitleBold;
  TextStyle textStylePrimaryBoldName;

  List<Tarea> listEnviados = [];
  List<Tarea> listRecibidos = [];
  List<Usuario> listUser = [];
  List<Caso> listaCasos = [];
  List<dynamic> listWidgetsHome = [];

  Map<int,Usuario> mapIdUser = {};
  Map<int,List> mapDataUserHome = {};

  TextEditingController controlleBuscador = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.black, spacing: 1);
    textStylePrimaryLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.015, color: WalkieTaskColors.black, spacing: 1);
    textStylePrimaryLitleRed = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.015, color: WalkieTaskColors.color_DD7777, spacing: 1, fontWeight: FontWeight.bold);
    textStylePrimaryLitleBold = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.015, color: WalkieTaskColors.black, spacing: 1,);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black,);
    textStylePrimaryTitleBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.028, color: WalkieTaskColors.black);
    textStylePrimaryBoldName = WalkieTaskStyles().styleHelveticaneueRegular(fontWeight: FontWeight.bold,size: alto * 0.02,color: WalkieTaskColors.black,spacing: 0.5);

    listEnviados = widget.listEnviadosRes;
    listRecibidos = widget.listRecibidos;
    listUser = widget.listUserRes;
    listaCasos = widget.listaCasosRes;
    mapIdUser = widget.mapIdUserRes;
    mapDataUserHome = widget.mapDataUserHome;
    listWidgetsHome = widget.listWidgetsHome;

    int cont = 0;
    //listUser.forEach((element) { if(element.contact == 1){ cont++; }});
    cont = listWidgetsHome.length;

    final posPersonalProvider = Provider.of<HomeProvider>(context);
    posPersonal = posPersonalProvider.posPersonal;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: WalkieTaskColors.white,
        bottomNavigationBar: posPersonal == 2 ?
            Container(
              height: alto * 0.06,
              margin: EdgeInsets.only(bottom: alto * 0.01),
              child: _reminderPersonal(),
            )
            : Container(height: 5,),
        body: cont == 0 ? _taskIsEmpty() : _taskForUsers(),
      ),
    );
  }

  Widget _taskIsEmpty(){
    return SingleChildScrollView(
      child: Container(
        width: ancho,
        child: Column(
          children: [
            posPersonal == 1 ? SizedBox(height: alto * 0.02,) : Container(),
            posPersonal == 1 ? _reminderPersonal() : Container(),
            Container(
              padding: EdgeInsets.only(top: alto * 0.05, left: ancho * 0.06, right: ancho * 0.06),
              width: ancho,
              child: Text(translate(context: context, text: 'usersSendTasks.'),style: textStylePrimary, textAlign: TextAlign.left,),
            ),
            SizedBox(height: alto * 0.02,),
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              width: ancho,
              child: Text(translate(context: context, text: 'invitingPeopleHere'),
                style: textStylePrimary, textAlign: TextAlign.left,),
            ),
            SizedBox(height: alto * 0.04,),
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              height: alto * 0.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ViewImage().assetsImage("assets/image/image_home_empty.png").image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: alto * 0.04,),
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              child: Divider(),
            ),
            SizedBox(height: alto * 0.04,),
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              width: ancho,
              child: Text('${translate(context: context, text: 'sendPersonalReminders')}:',
                style: textStylePrimary, textAlign: TextAlign.left,),
            ),
            SizedBox(height: alto * 0.02,),
            posPersonal != 0 ? _reminderPersonal() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _taskForUsers(){

    return Container(
      margin: EdgeInsets.only(top: alto * 0.01),
      width: ancho,
      child: CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            expandedHeight: alto * 0.1,
            title: Container(
              width: ancho,
              child: Column(
                children: [
                  Container(
                    width: ancho,
                    child: Text(translate(context: context, text: 'search'), style: textStylePrimaryTitleBold,),
                  ),
                  SizedBox(height: alto * 0.01,),
                  buscador(),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              iconBuscador ? Container() : posPersonal == 1 ? SizedBox(height: alto * 0.02,) : Container(),
              iconBuscador ? Container() : posPersonal == 1 ? _reminderPersonal() : Container(),
              iconBuscador ? resultSearch() : _users()
            ]),
          ),
        ],
      ),
    );
  }

  Widget _users(){

    List<Widget> users = [];

    users.add(SizedBox(height: alto * 0.03,));

    //listWidgetsHome.add({ 'info' : element, 'type' : 'project' || 'user', 'date' : element.updated_at, 'cantTaskAssigned' : cantTaskAssigned, 'cantTaskSend' : cantTaskSend});
    listWidgetsHome.forEach((element) {
      if(element['type'] == 'user'){
        Usuario user = element['info'];
        if(widget.myUserRes == null || widget.myUserRes.id == null || user.id == widget.myUserRes.id || user.contact == 0) return Container();

        String userName = user != null ? user.name ?? '' : '';
        Widget avatarUserWidget = avatarWidget(alto: alto,text: userName.isEmpty ? '' : userName.substring(0,1).toUpperCase());
        if(user != null){
          if(user != null && user.avatar_100 != ''){
            avatarUserWidget = avatarWidgetImage(alto: alto,pathImage: user.avatar_100);
          }
        }

        bool favorite = user.fijo == 1;

        String dateDiff = translate(context: context, text: 'noDate');
        int cantRecived = 0;
        int cantSend = 0;
        bool redColor = false;
        if(mapDataUserHome[user.id] != null){
          if(mapDataUserHome[user.id][0] != ''){
            dateDiff = getDayDiff(mapDataUserHome[user.id][0]);
            redColor = dateDiff.contains('-');
            dateDiff = dateDiff.replaceAll('-', '');
          }

          mapDataUserHome[user.id][1].forEach((task){
            if(task.finalized != 1){ cantRecived++; }
          });
          mapDataUserHome[user.id][2].forEach((task){
            if(task.finalized != 1){ cantSend++; }
          });
        }

        users.add(
          InkWell(
            onTap: () => _onTapUser(user, false),
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                width: ancho,
                margin: EdgeInsets.only(bottom: alto * 0.01, right: ancho * 0.03, left: ancho * 0.03),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.03),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              decoration: new BoxDecoration(
                                color: bordeCirculeAvatar, // border color
                                shape: BoxShape.circle,
                              ),
                              child: avatarUserWidget,
                            ),
                          ),
                          favorite ? Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: EdgeInsets.only(top: alto * 0.035, left: ancho * 0.08),
                              child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    Expanded(child: Text('${user.name} ${user.surname}', style: textStylePrimaryBoldName,)),
                    Container(
                      width: ancho * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          redColor ?
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                                  height: alto * 0.02,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: ancho * 0.02),
                                Text(dateDiff,style: textStylePrimaryLitleRed,)
                              ],
                            ),
                          )
                              :
                          Text(dateDiff,style: textStylePrimaryLitleBold,),
                          Text('${translate(context: context, text: 'received')}: $cantRecived',style: textStylePrimaryLitle,textAlign: TextAlign.right,),
                          Text('${translate(context: context, text: 'sent_2')}: $cantSend',style: textStylePrimaryLitle, textAlign: TextAlign.right,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                _buttonSliderAction(user.fijo == 0 ? translate(context: context, text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),Colors.yellow[600],WalkieTaskColors.white,1, user),
              ],
            ),
          ),
        );
        users.add(
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              child: Divider(),
            )
        );
      }
      if(element['type'] == 'project'){
        Caso project = element['info'];
        if(widget.myUserRes == null || widget.myUserRes.id == null || project == null ) return Container();

        String nameProject = project.name ?? '';
        bool favorite = project.is_priority == 1;
        String cantTask = '${element['cantTaskAssigned'].length + element['cantTaskSend'].length}' ?? '0';
        String cantAssigned = '${element['cantTaskAssigned'].length}' ?? '0';

        bool blueOrRed = true;
        for(int x = 0; x < element['cantTaskAssigned'].length; x++){
          Tarea taskAssigned = element['cantTaskAssigned'][x];
          if(taskAssigned.deadline.isNotEmpty){
            DateTime dateEnd = DateTime.parse(taskAssigned.deadline);
            if(dateEnd.difference(DateTime.now()).inDays > 0){
              blueOrRed = false;
            }
          }
        }

        users.add(
          InkWell(
            onTap: () => goToChatProject(project,element),
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                width: ancho,
                margin: EdgeInsets.only(bottom: alto * 0.01, right: ancho * 0.03, left: ancho * 0.03),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.03),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              decoration: new BoxDecoration(
                                color: bordeCirculeAvatar, // border color
                                shape: BoxShape.circle,
                              ),
                              child: avatarWidgetProject(alto: alto, radius: 0.03, text: '${nameProject.isEmpty ? '' : nameProject.substring(0,1).toUpperCase()}'),
                            ),
                          ),
                          favorite ? Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: EdgeInsets.only(top: alto * 0.035, left: ancho * 0.08),
                              child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    Expanded(child: Text('${project.name}', style: textStylePrimaryBoldName,)),
                    Container(
                      width: ancho * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Opacity(
                            opacity: cantTask == '0' ? 0.5 : 1,
                            child: Text('${translate(context: context, text: 'tasks')}: $cantTask',style: textStylePrimaryLitle,textAlign: TextAlign.right,),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              cantAssigned == '0' ? Container() :
                              blueOrRed ? Container() :
                              Container(
                                padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                                height: alto * 0.02,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              cantAssigned == '0' ? Container() : blueOrRed ?
                              Container(
                                margin: EdgeInsets.only(right: ancho * 0.01),
                                child: Icon(Icons.circle, color: WalkieTaskColors.color_76ADE3,size: alto * 0.015,),
                              ) :
                              Container(
                                margin: EdgeInsets.only(right: ancho * 0.01),
                                child: Icon(Icons.circle, color: WalkieTaskColors.color_EA7575,size: alto * 0.015,),
                              ),
                              Opacity(
                                opacity: cantAssigned == '0' ? 0.5 : 1,
                                child: Text('${translate(context: context, text: 'assigned')}: $cantAssigned',style: textStylePrimaryLitle, textAlign: TextAlign.right,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                _buttonSliderActionProjects(favorite ? translate(context: context, text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),Colors.yellow[600],WalkieTaskColors.white,1, project),
              ],
            ),
          ),
        );
        users.add(
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              child: Divider(),
            )
        );
      }
    });

    if(posPersonal == 0){
      users.add(_reminderPersonal());
    }

    users.add(SizedBox(height: alto * 0.03,));

    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children:  users,
        ),
      ),
    );
  }

  Widget _reminderPersonal(){

    String dateDiff = translate(context: context, text: 'noDate');
    int cant = 0;
    bool redColor = false;
    if(widget.myUserRes != null && mapDataUserHome[widget.myUserRes.id] != null){
      if(mapDataUserHome[widget.myUserRes.id][0] != ''){
        dateDiff = getDayDiff(mapDataUserHome[widget.myUserRes.id][0]);
        redColor = dateDiff.contains('-');
      }

      mapDataUserHome[widget.myUserRes.id][2].forEach((task) {
        if(task.finalized != 1){ cant++; }
      });
    }

    return InkWell(
      onTap: () => _onTapUser(widget.myUserRes, true),
      child: Container(
        padding: EdgeInsets.only(left: ancho * 0.03, right: ancho * 0.03),
        width: ancho,
        child: Row(
          children: [
            Container(
              height: alto * 0.06,
              width: alto * 0.06,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ViewImage().assetsImage("assets/image/icon_personal.png").image,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: ancho * 0.02),
                width: ancho,
                child: Text(translate(context: context, text: 'mePersonalReminders'),
                  style: textStylePrimaryBoldName, textAlign: TextAlign.left,),
              ),
            ),
            Container(
              width: ancho * 0.26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  redColor ?
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                          height: alto * 0.02,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: ancho * 0.02),
                        Text(dateDiff.replaceAll('-', ''),style: textStylePrimaryLitleRed,)
                      ],
                    ),
                  )
                      :
                  Text(dateDiff.replaceAll('-', ''),style: textStylePrimaryLitleBold,),
                  Text('${translate(context: context, text: 'reminders')}: $cant',style: textStylePrimaryLitle,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapUser(Usuario user, bool personal){
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) =>
        new DetailsTasksForUser(
          user: user,
          isPersonal: personal,
          mapDataUserHome: mapDataUserHome,
          listaCasos: listaCasos,
          blocTaskSend: widget.blocTaskSend,
          blocTaskReceived: widget.blocTaskReceived,
          blocIndicatorProgress: widget.blocIndicatorProgress,
          updateData: widget.updateData,
          blocAudioChangePage: widget.blocAudioChangePage,
        )));
  }

  Widget buscador(){
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: alto * 0.04,
              child: TextFildGeneric(
                onChanged: (text) {
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
                sizeBorder: 1.2,
                sizeHeight: alto * 0.045,
                textAlign: TextAlign.left,
                hintText: translate(context: context, text: 'search'),
                prefixIcon: InkWell(
                  child: iconBuscador ? Icon(Icons.clear) : Icon(Icons.search),
                  onTap: (){
                    if(iconBuscador){
                      _closeSearch();
                    }
                  },
                ),
                colorBack: WalkieTaskColors.color_E3E3E3,
                textEditingController: controlleBuscador,
                initialValue: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultSearch(){

    List<Widget> listW = resultSearchUsers();

    return Container(
      width: ancho,
      height: alto <= 600 ? alto * 0.66 : alto * 0.7,
      //color: Colors.amber,
      child: Column(
        children: [
          Container(
            width: ancho,
            height: listW.length > 3 ? alto * 0.32 : alto * 0.1,
            //color: Colors.red,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: listW,
              ),
            ),
          ),
          Container(
            width: ancho,
            color: WalkieTaskColors.color_B7B7B7,
            height: alto * 0.003,
          ),
          Container(
            width: ancho,
            height: alto * 0.32,
            // color: Colors.blue,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: alto * 0.03,),
                Container(
                  width: ancho,
                  margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.1),
                  child: Text(translate(context: context, text: 'tasks'), style: textStylePrimaryTitleBold,),
                ),
                SizedBox(height: alto * 0.015,),
                Container(
                  height: alto * 0.23,
                  width: ancho,
                  // color: Colors.orange,
                  child: SingleChildScrollView(
                    child: Column(
                      children: resultSearchTask()
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _closeSearch(){
    controlleBuscador.text = '';
    iconBuscador = false;
    controlleBuscador.clear();
    FocusScope.of(context).requestFocus(new FocusNode());
    //WidgetsBinding.instance.addPostFrameCallback((_) => controlleBuscador.clear());
    setState(() {});
  }

  List<Widget> resultSearchUsers(){
    List<Widget> users = [];

    users.add(SizedBox(height: alto * 0.03,));

    listWidgetsHome.forEach((element) {
      if(element['type'] == 'user'){
        Usuario user = element['info'];
        if(widget.myUserRes == null || widget.myUserRes.id == null || user.id == widget.myUserRes.id || user.contact == 0) return Container();

        if((!user.name.toLowerCase().contains(controlleBuscador.text.toLowerCase())) &&
            (!user.surname.toLowerCase().contains(controlleBuscador.text.toLowerCase()))) return Container();

        String userName = user != null ? user.name ?? '' : '';
        Widget avatarUserWidget = avatarWidget(alto: alto,text: userName.isEmpty ? '' : userName.substring(0,1).toUpperCase());
        if(user != null){
          if(user != null && user.avatar_100 != ''){
            avatarUserWidget = avatarWidgetImage(alto: alto,pathImage: user.avatar_100);
          }
        }

        bool favorite = user.fijo == 1;

        String dateDiff = translate(context: context, text: 'noDate');
        int cantRecived = 0;
        int cantSend = 0;
        bool redColor = false;
        if(mapDataUserHome[user.id] != null){
          if(mapDataUserHome[user.id][0] != ''){
            dateDiff = getDayDiff(mapDataUserHome[user.id][0]);
            redColor = dateDiff.contains('-');
            dateDiff = dateDiff.replaceAll('-', '');
          }

          mapDataUserHome[user.id][1].forEach((task){
            if(task.finalized != 1){ cantRecived++; }
          });
          mapDataUserHome[user.id][2].forEach((task){
            if(task.finalized != 1){ cantSend++; }
          });
        }

        users.add(
          InkWell(
            onTap: () => _onTapUser(user, false),
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                width: ancho,
                margin: EdgeInsets.only(bottom: alto * 0.01, right: ancho * 0.03, left: ancho * 0.03),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.03),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              decoration: new BoxDecoration(
                                color: bordeCirculeAvatar, // border color
                                shape: BoxShape.circle,
                              ),
                              child: avatarUserWidget,
                            ),
                          ),
                          favorite ? Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: EdgeInsets.only(top: alto * 0.035, left: ancho * 0.08),
                              child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    Expanded(child: Text('${user.name} ${user.surname}', style: textStylePrimaryBoldName,)),
                    Container(
                      width: ancho * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          redColor ?
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                                  height: alto * 0.02,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: ancho * 0.02),
                                Text(dateDiff,style: textStylePrimaryLitleRed,)
                              ],
                            ),
                          )
                              :
                          Text(dateDiff,style: textStylePrimaryLitleBold,),
                          Text('${translate(context: context, text: 'received')}: $cantRecived',style: textStylePrimaryLitle,textAlign: TextAlign.right,),
                          Text('${translate(context: context, text: 'sent_2')}: $cantSend',style: textStylePrimaryLitle, textAlign: TextAlign.right,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                _buttonSliderAction(user.fijo == 0 ? translate(context: context, text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),Colors.yellow[600],WalkieTaskColors.white,1, user),
              ],
            ),
          ),
        );
        users.add(
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              child: Divider(),
            )
        );
      }
      if(element['type'] == 'project'){
        Caso project = element['info'];
        if(widget.myUserRes == null || widget.myUserRes.id == null || project == null ) return Container();

        if(!project.name.toLowerCase().contains(controlleBuscador.text.toLowerCase())) return Container();

        String nameProject = project.name ?? '';
        bool favorite = project.is_priority == 1;
        String cantTask = element['cantTask'] ?? '0';
        String cantAssigned = element['cantAssigned'] ?? '0';

        users.add(
          InkWell(
            onTap: () => goToChatProject(project,element),
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                width: ancho,
                margin: EdgeInsets.only(bottom: alto * 0.01, right: ancho * 0.03, left: ancho * 0.03),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.03),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              decoration: new BoxDecoration(
                                color: bordeCirculeAvatar, // border color
                                shape: BoxShape.circle,
                              ),
                              child: avatarWidgetProject(alto: alto, radius: 0.03, text: '${nameProject.isEmpty ? '' : nameProject.substring(0,1).toUpperCase()}'),
                            ),
                          ),
                          favorite ? Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: EdgeInsets.only(top: alto * 0.035, left: ancho * 0.08),
                              child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    Expanded(child: Text('${project.name}', style: textStylePrimaryBoldName,)),
                    Container(
                      width: ancho * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${translate(context: context, text: 'tasks')}: $cantTask',style: textStylePrimaryLitle,textAlign: TextAlign.right,),
                          Text('${translate(context: context, text: 'assigned')}: $cantAssigned',style: textStylePrimaryLitle, textAlign: TextAlign.right,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                _buttonSliderActionProjects(favorite ? translate(context: context, text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),Colors.yellow[600],WalkieTaskColors.white,1, project),
              ],
            ),
          ),
        );
        users.add(
            Container(
              padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
              child: Divider(),
            )
        );
      }
    });

    if(users.length == 1){
      users.add(
        Container(
          width: ancho,
          margin: EdgeInsets.only(left: ancho * 0.1, right: ancho * 0.1),
          child: Text('${translate(context: context, text: 'NoMatchesFoundUsers')}.', style: textStylePrimary,)
        ),
      );
    }

    users.add(SizedBox(height: alto * 0.03,));

    return users;
  }

  List<Widget> resultSearchTask(){
    List<Widget> tasks = [];

    mapDataUserHome.forEach((key, list) {
      List listAll = [];
      list[1].forEach((task){listAll.add(task);});
      list[2].forEach((task){listAll.add(task);});


      listAll.forEach((task2) {
        Tarea task = task2;
        if(task.name.toLowerCase().contains(controlleBuscador.text.toLowerCase()) && task.finalized != 1){

          bool isRecived = false;
          if(task.user_responsability_id == widget.myUserRes.id){ isRecived = true;}

          bool working = task.working == 1;
          bool favorite = isRecived ? (task.is_priority_responsability == 1) : (task.is_priority == 1);

          String nameUser = '';
          if(mapIdUser != null && mapIdUser[task.user_id] != null){
            nameUser = mapIdUser[task.user_id].name;
          }

          String date = '';
          if(task.deadline.isNotEmpty){
            DateTime _dateTime = DateTime.parse(task.deadline);
            date = '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
          }

          tasks.add(
            IntrinsicHeight(
              child: Container(
                constraints: BoxConstraints(minHeight: alto * 0.08),
                key: ValueKey("value${task.id}"),
                padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
                color: Colors.white,
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  actions: <Widget>[
                    _buttonSliderActionTask(task.is_priority_responsability == 0 ? translate(context: context,text: 'highlight') : translate(context: context,text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.03,),Colors.yellow[600],WalkieTaskColors.white,1,task, isRecived),
                    //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                  ],
                  secondaryActions: <Widget>[
                    isRecived ? _buttonSliderActionTask(translate(context: context,text: 'working'),Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.03,),colorSliderTrabajando,WalkieTaskColors.white,3,task, isRecived) : null,
                    _buttonSliderActionTask(translate(context: context,text: 'ready'),Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.03,),colorSliderListo,WalkieTaskColors.white,4,task, isRecived),
                  ],
                  child: InkWell(
                    onTap: (){
                      clickTarea(task);
                      _closeSearch();
                    },
                    child: Container(
                      width: ancho,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          working ? Container(
                            width: ancho * 0.015,
                            color: WalkieTaskColors.color_89BD7D,
                          ) : Container(width: ancho * 0.015,),
                          favorite ? Container(
                            width: ancho * 0.055,
                            child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                          ) : Container(),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: ancho * 0.03, ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.name, style: textStylePrimaryBold,),
                                  Text(nameUser, style: textStylePrimaryLitle,),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: ancho * 0.25,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(date, style: textStylePrimary,),
                                task.url_audio.isNotEmpty ?
                                SoundTask(
                                  alto: alto * 0.03,
                                  colorStop: WalkieTaskColors.color_E07676,
                                  path: task.url_audio,
                                  idTask: task.id,
                                  page: bottonSelect.opcion1,
                                  blocAudioChangePage: widget.blocAudioChangePage,
                                ) : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          tasks.add(
              Container(
                padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
                child: Divider(),
              )
          );
        }
      });
    });

    if(tasks.length == 0){
      tasks.add(
        Container(
            width: ancho,
            margin: EdgeInsets.only(left: ancho * 0.1, right: ancho * 0.1),
            child: Text(translate(context: context, text: 'NoResults'), style: textStylePrimary,)
        ),
      );
    }

    tasks.add(SizedBox(height: alto * 0.03,));
    return tasks;
  }

  Widget _buttonSliderAction(String titulo,Icon icono,Color color,Color colorText,int accion, Usuario user){
    return IconSlideAction(
      color: color,
      iconWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icono,
          Text('$titulo',style: estiloLetras(alto * 0.013, Colors.white,fontFamily: 'helveticaneue2'),),
        ],
      ),
      onTap: () async {
        int res = 0;
        user.fijo = user.fijo == 1 ? 0 : 1;
        res = await  DatabaseProvider.db.updateUser(user);
        if(res == 1){
          widget.blocUserRes.inList.add(true);
        }
      },
    );
  }

  Widget _buttonSliderActionTask(String titulo,Icon icono,Color color,Color colorText,int accion,Tarea tarea, bool isRecived){
    return IconSlideAction(
      color: color,
      iconWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icono,
          Text('$titulo',style: estiloLetras(alto * 0.013, Colors.white,fontFamily: 'helveticaneue2'),),
        ],
      ),
      onTap: () async {
        if(accion == 1){
          //CAMBIAR ESTADO DE DESTACAR 0 = FALSE, 1 = TRUE
          if(isRecived){
            if(tarea.is_priority_responsability == 0){ tarea.is_priority_responsability = 1;}else{tarea.is_priority_responsability = 0;}
          }else{
            if(tarea.is_priority == 0){ tarea.is_priority = 1;}else{tarea.is_priority = 0;}
          }
          //GUARDAR LOCALMENTE
          if(await DatabaseProvider.db.updateTask(tarea) == 1){
            //AVISAR A PATRONBLOC DE TAREAS ENVIADAS PARA QUE SE ACTUALICE
            if(isRecived){
              widget.blocTaskReceived.inList.add(true);
            }else{
              widget.blocTaskSend.inList.add(true);
            }
            //ENVIAR A API
            try{
              await conexionHttp().httpSendFavorite(tarea,tarea.is_priority);
            }catch(e){
              //SI NO HAY CONEXION GUARDAR EN TABLA LOCAL
            }
          }
        }
        if(accion == 3){
          try{
            if(tarea.working == 0){
              showAlert(translate(context: context, text: 'TaskStarted'),WalkieTaskColors.color_89BD7D);
              tarea.working = 1;
              if(await DatabaseProvider.db.updateTask(tarea) == 1){
                if(isRecived){
                  widget.blocTaskReceived.inList.add(true);
                }else{
                  widget.blocTaskSend.inList.add(true);
                }
                await conexionHttp().httpTaskInit(tarea.id);
              }
            }else{
              showAlert(translate(context: context, text: 'TaskAlreadyStarted'),WalkieTaskColors.color_89BD7D);
            }
          }catch(e){
            print(e.toString());
          }
        }
        if(accion == 4){
          showAlert(translate(context: context, text: 'TaskFinished'),WalkieTaskColors.color_89BD7D);
          try{
            tarea.finalized = 1;
            if(await DatabaseProvider.db.updateTask(tarea) == 1){
              if(isRecived){
                widget.blocTaskReceived.inList.add(true);
              }else{
                widget.blocTaskSend.inList.add(true);
              }
              await conexionHttp().httpTaskFinalized(tarea.id);
            }
          }catch(e){
            print(e.toString());
          }
        }
      },
    );
  }

  Widget _buttonSliderActionProjects(String titulo,Icon icono,Color color,Color colorText,int accion, Caso project){
    return IconSlideAction(
      color: color,
      iconWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icono,
          Text('$titulo',style: estiloLetras(alto * 0.013, Colors.white,fontFamily: 'helveticaneue2'),),
        ],
      ),
      onTap: () async {
        int res = 0;
        project.is_priority = project.is_priority == 1 ? 0 : 1;
        res = await  DatabaseProvider.db.updateCase(project);
        if(res == 1){
          widget.blocCasos.inList.add(true);
          updateDateProject(project.id);
        }
      },
    );
  }

  void clickTarea(Tarea tarea,) async {
    widget.blocAudioChangePage.inList.add({'page' : bottonSelect.opcion1});
    try{
      if(tarea.name.isEmpty){
        var result  = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => new AddNameTask(tareaRes: tarea,)));
        if(result){
          try{
            widget.updateData.actualizarListaEnviados(widget.blocTaskSend, null);
            widget.updateData.actualizarListaRecibidos(widget.blocTaskReceived, null);
          }catch(e){
            print(e.toString());
          }
        }
      }else{
        Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
            new ChatForTarea(
              tareaRes: tarea,
              listaCasosRes: listaCasos,
              blocTaskSend: widget.blocTaskReceived,
            )));
      }
    }catch(e){
      print(e.toString());
    }
  }

  void goToChatProject(Caso project,Map<String,dynamic> widgetHome){
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) =>
        new ChatForProject(
          project: project,
          widgetHome: widgetHome,
          blocCasos: widget.blocCasos,
          mapIdUser: mapIdUser,
          push: widget.push,
          myUser: widget.myUserRes,
          blocAudioChangePage: widget.blocAudioChangePage,
          blocTaskReceived: widget.blocTaskReceived,
          blocTaskSend: widget.blocTaskSend,
          listaCasos: widget.listaCasosRes,
          blocIndicatorProgress: widget.blocIndicatorProgress,
          updateData: widget.updateData,
        )));
  }

  Future<void> updateDateProject(int idPRojects) async{
    try{
      var response = await conexionHttp().httpUpdateDateProject(idPRojects);
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        UpdateData().actualizarCasos(widget.blocCasos);
      }
    }catch(e){
      print(e.toString());
    }
  }
}