import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Firebase/Notification/push_notifications_provider.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/format_deadline.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/switch_button.dart';
import 'package:walkietaskv2/utils/task_sound.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';
import 'package:walkietaskv2/views/Home/NavigatorBotton.dart';

import '../Chat/ChatForTarea.dart';

class ListadoTareasRecibidas extends StatefulWidget {

  ListadoTareasRecibidas({this.push,@required this.blocAudioChangePage,
    this.mapIdUserRes,this.listRecibidos,this.blocTaskReceivedRes,this.listaCasosRes,this.myUserRes});
  final Map<int,Usuario> mapIdUserRes;
  final List<Tarea> listRecibidos;
  final BlocTask blocTaskReceivedRes;
  final List<Caso> listaCasosRes;
  final Usuario myUserRes;
  final PushProvider push;
  final BlocProgress blocAudioChangePage;
  @override
  _ListadoTareasState createState() => _ListadoTareasState();
}

class _ListadoTareasState extends State<ListadoTareasRecibidas> {

  List<Tarea> listaTareas = new List<Tarea>();
  double alto = 0;
  double ancho = 0;
  List<Tarea> listRecibidos = [];

  Map<int,Usuario> mapIdUser;
  BlocTask blocTaskReceived;

  bool valueSwitch = false;
  Map<int,bool> mapAppBar = {0:true,1:false,2:false};
  UpdateData updateData = new UpdateData();
  conexionHttp conexionHispanos = new conexionHttp();

  Map<int,bool> openForUserTask = {};
  Map<int,bool> openForProyectTask = {0 : false};
  Map<int,Caso> mapCasos = {};

  AudioPlayer audioPlayer;
  int taskReproduciendo = 0;

  TextStyle textStylePrimary = TextStyle();
  TextStyle textStylePrimaryBold = TextStyle();
  TextStyle textStyleProject = TextStyle();
  TextStyle textStyleNotTitle = TextStyle();

  StreamSubscription streamSubscriptionTaskRecived;

  @override
  void initState() {
    super.initState();
    audioPlayer = new AudioPlayer();
    listenerAudio();
    blocTaskReceived = widget.blocTaskReceivedRes;
    widget.listaCasosRes.forEach((element) { mapCasos[element.id] = element;});
    _inicializar();
    _inicializar2();
    _inicializar3();
    _inicializarShared();
    _notificationListener();
    //_inicializarPatronBlocTaskRecived();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionTaskRecived?.cancel();
    try{
      audioPlayer?.stop();
    }catch(_){}
  }

  _inicializar(){
    mapIdUser = widget.mapIdUserRes;
    if(valueSwitch){
      orderListTaskDeadLine();
    }else{
      listRecibidos = widget.listRecibidos;
      //orderListRecived(widget.listRecibidos);
    }
  }

  _inicializar2(){
    if(widget.mapIdUserRes != null){
      mapIdUser.forEach((key, value) {
        openForUserTask[key] = false;
      });
    }
    setState(() {});
  }

  _inicializar3(){
    if(widget.listaCasosRes.isNotEmpty){
      mapCasos.forEach((key, value) {
        openForProyectTask[key] = false;
      });
    }
    setState(() {});
  }

  Future<void> _inicializarShared() async {
    valueSwitch = await SharedPrefe().getValue('walkietaskFilterDate2') ?? false;
    setState(() {});
    _updateDataNewFirebase();
    _checkListChat();
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    textStylePrimary = WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D,spacing: 0.5);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D,spacing: 0.5);
    textStyleProject = WalkieTaskStyles().stylePrimary(size: alto * 0.018, color: WalkieTaskColors.color_4D4D4D,spacing: 0.5);
    textStyleNotTitle = WalkieTaskStyles().styleNunitoRegular(size: alto * 0.018, color: WalkieTaskColors.primary,spacing: 0.5);

    _inicializar();
    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      body: _contenido(),
    );
  }

  Widget _contenido(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: ancho,
            color: Colors.grey[100],
            child: _appBArMenu(),
          ),
          mapAppBar[0] ? Container(
            width: ancho,
            color: WalkieTaskColors.white,
            child: _filterForDate(),
          ) : Container(),
          listRecibidos.isEmpty ?
          Container(
            width: ancho,
            height: alto * 0.8,
            child: Center(
              child: Text(translate(context: context, text: 'noReceivedTasks'), style: textStylePrimary,),
            ),
          ) :
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                mapAppBar[0] ? _listado() : Container(),
                mapAppBar[1] ? _listadoUser() : Container(),
                mapAppBar[2] ? _listadoProyect() : Container(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _filterForDate(){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(right: ancho * 0.03, top: alto * 0.01, bottom: alto * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: ancho * 0.02),
            child: CustomSwitchLocal(
              value: valueSwitch,
              sizeH: alto * 0.022,
              sizeW: ancho * 0.11,
              onChanged: (bool val) async {
                await SharedPrefe().setBoolValue('walkietaskFilterDate2',val);
                setState(() {
                  valueSwitch = !valueSwitch;
                });
              },
              colorBgOff: WalkieTaskColors.grey,
              colorBgOn: WalkieTaskColors.primary,
              sizeCircule: alto * 0.025,
            ),
          ),
          Text(translate(context: context, text: 'deadline'), style: WalkieTaskStyles().styleHelveticaneueRegular(color: WalkieTaskColors.primary, size: alto * 0.018, fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

  Widget _appBArMenu(){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05, top: alto * 0.007,),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _appBArMenuText(translate(context: context, text: 'last'),0),
          ),
          Expanded(
            child: _appBArMenuText(translate(context: context, text: 'user'),1),
          ),
          Expanded(
            child: _appBArMenuText(translate(context: context, text: 'projects').toUpperCase(),2),
          ),
        ],
      ),
    );
  }

  Widget _appBArMenuText(String text, int index){
    return InkWell(
      onTap: (){
        mapAppBar[0] = false;
        mapAppBar[1] = false;
        mapAppBar[2] = false;
        mapAppBar[index] = true;
        widget.blocAudioChangePage.inList.add({'page' : bottonSelect.opcion1});
        setState(() {});
      },
      child: Column(
        children: <Widget>[
          Text(text, style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.016, color: WalkieTaskColors.primary),),
          mapAppBar[index] ? Container(
            width: ancho * 0.18,
            height: alto * 0.006,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: WalkieTaskColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  Widget _listado(){
    double h = alto > 600 ? alto * 0.8 : alto * 0.7;

    return Container(
        height: h,
        child: ReorderableListView(
          children: List.generate(listRecibidos.length, (index) {
            Tarea tarea = listRecibidos[index];

            if(tarea.finalized == 1){
              return Container(
                key: ValueKey("value$index"),
              );
            }

            return Container(
              key: ValueKey("value$index"),
              padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: _tareas(tarea),
                actions: <Widget>[
                  _buttonSliderAction(tarea.is_priority_responsability == 0 ? translate(context: context,text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,tarea),
                  //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  _buttonSliderAction(translate(context: context, text: 'working'),Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.045,),colorSliderTrabajando,WalkieTaskColors.white,3,tarea),
                  _buttonSliderAction(translate(context: context, text: 'ready'),Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.045,),colorSliderListo,WalkieTaskColors.white,4,tarea),
                ],
              ),
            );
          }),
          onReorder: (int oldIndex, int newIndex) {
            _updateMyItems(oldIndex, newIndex);
          },
        )
    );
  }

  Widget _tareas(Tarea tarea, ){

    bool favorite = tarea.is_priority_responsability == 1;

    bool isNew = false;
    listViewTaskNew.forEach((element) {
      if(element == tarea.id.toString()){
        isNew = true;
      }
    });

    bool working = tarea.working == 1;


    String daysLeft = getDayDiff(tarea.deadline);

    String proyectName = translate( context: context, text: 'noAssignedProject');
    if(tarea.project_id != null && tarea.project_id != 0 && mapCasos[tarea.project_id] != null){
      proyectName = mapCasos[tarea.project_id].name;
    }

    String nameUser = '';
    if(mapIdUser[tarea.user_id] != null){
      nameUser = '${mapIdUser[tarea.user_id].name} ${mapIdUser[tarea.user_id].surname}';
      if(widget.myUserRes != null && widget.myUserRes.id != null && widget.myUserRes.id == mapIdUser[tarea.user_id].id){
        nameUser = translate(context: context, text: 'remindersPersonal');
      }
    }

    Widget avatarUser = avatarWidget(alto: alto,text: nameUser.isEmpty ? '' : nameUser.substring(0,1).toUpperCase());
    if(mapIdUser != null){
      if(mapIdUser[tarea.user_id] != null && mapIdUser[tarea.user_id].avatar_100 != ''){
        avatarUser = avatarWidgetImage(alto: alto,pathImage: mapIdUser[tarea.user_id].avatar_100);
      }
    }

    int chatCont = 0;
    listCheckChat.forEach((element) {
      if(tarea.id.toString() == element){
        chatCont++;
      }
    });
    double radiusChat = 0.012;
    if(chatCont >= 10 && chatCont < 100){radiusChat = 0.014; }
    if(chatCont > 100){radiusChat = 0.018; }

    bool activity = chatCont != 0;
    if(!activity) { activity = isNew;}

    return InkWell(
      onTap: () =>clickTarea(tarea),
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              working ? Container(
                width: ancho * 0.015,
                color: WalkieTaskColors.color_89BD7D,
              ) : Container(width: ancho * 0.015,),
              Container(
                width: ancho * 0.18,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: ancho * 0.015),
                      child: Container(
                        padding: const EdgeInsets.all(3.0), // borde width
                        decoration: new BoxDecoration(
                          color: bordeCirculeAvatar, // border color
                          shape: BoxShape.circle,
                        ),
                        child: avatarUser,
                      ),
                    ),
                    favorite ? Container(
                      margin: EdgeInsets.only(left: ancho * 0.1, top: alto * 0.04),
                      child: Icon(Icons.star,color: WalkieTaskColors.yellow, size: alto * 0.03,),
                    ) : Container(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('$nameUser', style: activity ? textStylePrimaryBold : textStylePrimary),
                      Text(tarea.name.isNotEmpty ? tarea.name : translate(context: context, text: 'untitledTask'),
                        style: tarea.name.isNotEmpty ? (activity ? textStylePrimaryBold : textStylePrimary) : textStyleNotTitle,),
                      Text(proyectName,style: textStyleProject,),
                    ],
                  ),
                ),
              ),
              SoundTask(
                alto: alto * 0.03,
                colorStop: WalkieTaskColors.color_E07676,
                path: tarea.url_audio,
                idTask: tarea.id,
                blocAudioChangePage: widget.blocAudioChangePage,
                page: bottonSelect.opcion2,
                chatCont: chatCont != 0 ? Container(
                  margin: EdgeInsets.only(right: ancho * 0.002),
                  child: CircleAvatar(
                    backgroundColor: WalkieTaskColors.primary,
                    // 100 alto * 0.018, / 10 alto * 0.014, / 1 alto * 0.012,
                    radius: alto * radiusChat,
                    child: Text('$chatCont',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                  ),
                ) : Container(),
                textDate: Text(daysLeft.replaceAll('-', ''),style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: daysLeft.contains('-') ? WalkieTaskColors.color_E07676 : Colors.grey[600]),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listadoUser(){
    Map<int,List<Tarea>> mapTask = {};
    listRecibidos.forEach((element) {
      if(mapTask[element.user_id] == null){ mapTask[element.user_id] = [];}
      mapTask[element.user_id].add(element);
    });

    double h = alto > 600 ? alto * 0.8 : alto * 0.75;

    return Container(
      width: ancho,
      height: h,
      child: ListView.builder(
        itemCount: mapTask.length,
        itemBuilder: (context, index){
          List<Tarea> listTask = mapTask[mapTask.keys.elementAt(index)];
          return _tareasUser(mapIdUser[listTask[0].user_id], listTask);
        },
      ),
    );
  }

  Widget _tareasUser(Usuario user, List<Tarea> listTask){


    List<Widget> listTaskWidget = listTaskGet(user, listTask);

    String nameUser = '${user.name} ${user.surname}';
    if(widget.myUserRes.id == user.id){
      nameUser = translate(context: context, text: 'remindersPersonal');
    }

    Widget avatarUser = avatarWidget(alto: alto,text: nameUser.isEmpty ? '' : nameUser.substring(0,1).toUpperCase());
    if(mapIdUser != null){
      if(user != null && user.avatar_100 != ''){
        avatarUser = avatarWidgetImage(alto: alto,pathImage: user.avatar_100);
      }
    }

    int cantTask = 0;
    listTask.forEach((element) {  if(element.finalized == 0){ cantTask++; } });

    return Container(
      width: ancho,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: (){
              Map<int,bool> mapAux = openForUserTask;
              bool res = openForUserTask[user.id];
              mapAux.forEach((key, value) { openForUserTask[key] = false; });
              openForUserTask[user.id] = !res;
              setState(() {});
            },
            child: Container(
              width: ancho,
              padding: EdgeInsets.all(alto * 0.015),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(3.0), // borde width
                    decoration: new BoxDecoration(
                      color: bordeCirculeAvatar, // border color
                      shape: BoxShape.circle,
                    ),
                    child: avatarUser,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: ancho * 0.03,right: ancho * 0.03,),
                      child: Text('$nameUser',
                          style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_76ADE3)),
                    ),
                  ),
                  Container(
                    child: Text('($cantTask ${cantTask < 1 ? translate(context: context, text: 'tasks').substring(0,translate(context: context, text: 'tasks').length - 1) : translate(context: context, text: 'tasks')})',
                        style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 1)),
                  ),
                  Container(
                    child: !openForUserTask[user.id] ?
                    Container(
                      width: ancho * 0.12,
                      height: alto * 0.06,
                      child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
                    ) :
                    Container(
                      width: ancho * 0.12,
                      height: alto * 0.06,
                      child: Image.asset('assets/image/icon_open_option.png',fit: BoxFit.fill,color: Colors.grey,),
                    ),
                  ),
                ],
              ),
            ),
          ),
          openForUserTask[user.id] ?
          Container(
            width: ancho,
            child: Column(
              children: listTaskWidget,
            ),
          ) : Container(),
          Container(
            height: 1,
            margin: EdgeInsets.only(left: ancho * 0.2, right: ancho * 0.2, top: alto * 0.01),
            color: WalkieTaskColors.color_E3E3E3,
          )
        ],
      ),
    );
  }

  List<Widget> listTaskGet(Usuario user, List<Tarea> listTask){
    List<Widget> listTaskRes = [];
    listTask.forEach((task) {

      if(task.finalized != 1){
        String daysLeft = getDayDiff(task.deadline);

        bool working = task.working == 1;
        bool favorite = task.is_priority_responsability == 1;

        String proyectName = translate(context: context, text: 'noAssignedProject');
        if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
          proyectName = mapCasos[task.project_id].name;
        }
        int chatCont = 0;
        listCheckChat.forEach((element) {
          if(task.id.toString() == element){
            chatCont++;
          }
        });
        double radiusChat = 0.012;
        if(chatCont >= 10 && chatCont < 100){radiusChat = 0.014; }
        if(chatCont > 100){radiusChat = 0.018; }

        listTaskRes.add(
            IntrinsicHeight(
              child: Container(
                key: ValueKey("value${task.id}"),
                padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
                color: Colors.white,
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  actions: <Widget>[
                    _buttonSliderAction(task.is_priority_responsability == 0 ? translate(context: context,text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.03,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,task),
                    //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                  ],
                  secondaryActions: <Widget>[
                    _buttonSliderAction(translate(context: context, text: 'working'),Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.03,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                    _buttonSliderAction(translate(context: context, text: 'ready'),Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.03,),colorSliderListo,WalkieTaskColors.white,4,task),
                  ],
                  child: InkWell(
                    onTap: () =>clickTarea(task),
                    child: Container(
                      width: ancho,
                      padding: EdgeInsets.only(left: ancho * 0.005, right: ancho * 0.02),
                      child: Row(
                        children: <Widget>[
                          working ? Container(
                            width: ancho * 0.015,
                            color: WalkieTaskColors.color_89BD7D,
                          ) : Container(width: ancho * 0.015,),
                          favorite ? Container(
                            width: ancho * 0.055,
                            child: Icon(Icons.star,color: WalkieTaskColors.yellow, size: alto * 0.03,),
                          ) : Container(width: ancho * 0.055,),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: ancho * 0.01, ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(task.name.isEmpty ? translate(context: context, text: 'noName') : task.name,
                                      style: textStylePrimaryBold),
                                  Text(proyectName,
                                    style: textStylePrimary,),
                                ],
                              ),
                            ),
                          ),
                          SoundTask(
                            alto: alto * 0.03,
                            colorStop: WalkieTaskColors.color_E07676,
                            path: task.url_audio,
                            idTask: task.id,
                            blocAudioChangePage: widget.blocAudioChangePage,
                            page: bottonSelect.opcion2,
                            chatCont: chatCont != 0 ? Container(
                              margin: EdgeInsets.only(right: ancho * 0.002),
                              child: CircleAvatar(
                                backgroundColor: WalkieTaskColors.primary,
                                // 100 alto * 0.018, / 10 alto * 0.014, / 1 alto * 0.012,
                                radius: alto * radiusChat,
                                child: Text('$chatCont',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                              ),
                            ) : Container(),
                            textDate: Text(daysLeft.replaceAll('-', ''),style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: daysLeft.contains('-') ? WalkieTaskColors.color_E07676 : Colors.grey[600]),),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
        );
      }
    });
    return listTaskRes;
  }

  Widget _listadoProyect(){
    Map<int,List<Tarea>> mapTask = {};
    listRecibidos.forEach((element) {
      int idProyect = element.project_id ?? 0;
      if(mapCasos[idProyect] == null){
        idProyect = 0;
      }
      if(mapTask[idProyect] == null){ mapTask[idProyect] = [];}
      mapTask[idProyect].add(element);
    });

    double h = alto > 600 ? alto * 0.8 : alto * 0.75;

    return Container(
      width: ancho,
      height: h,
      child: ListView.builder(
        itemCount: mapTask.length,
        itemBuilder: (context, index){
          List<Tarea> listTask = mapTask[mapTask.keys.elementAt(index)];
          Caso proyect;
          if(listTask[0].project_id != null && mapCasos[listTask[0].project_id] != null){
            proyect = mapCasos[listTask[0].project_id];
          }
          return _tareasProyect(proyect, listTask);
        },
      ),
    );
  }

  Widget _tareasProyect(Caso proyect, List<Tarea> listTask,){

    String nameProyect = proyect == null ? translate(context: context, text: 'noProjectAssigned') : proyect.name;
    int keyOpen = proyect == null ? 0 : proyect.id;

    List<Widget> listTaskWidget = listTaskGetProyect(proyect, listTask);

    int cantTask = 0;
    listTask.forEach((element) {  if(element.finalized == 0){ cantTask++; } });

    return Container(
      width: ancho,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: (){
              Map<int,bool> mapAux = openForProyectTask;
              bool res = openForProyectTask[keyOpen];
              mapAux.forEach((key, value) { openForProyectTask[key] = false; });
              openForProyectTask[keyOpen] = !res;
              setState(() {});
            },
            child: Container(
              width: ancho,
              padding: EdgeInsets.all(alto * 0.015),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: ancho * 0.03,right: ancho * 0.03,),
                      child: Text(nameProyect,
                          style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_76ADE3)),
                    ),
                  ),
                  Container(
                    child: Text('($cantTask ${cantTask < 1 ? translate(context: context, text: 'tasks').substring(0,translate(context: context, text: 'tasks').length - 1) : translate(context: context, text: 'tasks')})',
                        style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 1)),
                  ),
                  Container(
                    child: !openForProyectTask[keyOpen] ?
                    Container(
                      width: ancho * 0.12,
                      height: alto * 0.06,
                      child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
                    ) :
                    Container(
                      width: ancho * 0.12,
                      height: alto * 0.06,
                      child: Image.asset('assets/image/icon_open_option.png',fit: BoxFit.fill,color: Colors.grey,),
                    ),
                  ),
                ],
              ),
            ),
          ),
          openForProyectTask[keyOpen] ?
          Container(
            width: ancho,
            child: Column(
              children: listTaskWidget,
            ),
          ) : Container(),
          Container(
            height: 1,
            margin: EdgeInsets.only(left: ancho * 0.2, right: ancho * 0.2, top: alto * 0.01),
            color: WalkieTaskColors.color_E3E3E3,
          )
        ],
      ),
    );
  }

  List<Widget> listTaskGetProyect(Caso proyect, List<Tarea> listTask){
    List<Widget> listTaskRes = [];
    for(int index = 0; index < listTask.length; index++) {
      Tarea task = listTask[index];
      if(task.finalized == 0){
        listTaskRes.add(
            InkWell(
              onTap: () =>clickTarea(task),
              child: Container(
                key: ValueKey("value$index"),
                padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
                color: Colors.white,
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: _tareas(task),
                  actions: <Widget>[
                    _buttonSliderAction(task.is_priority_responsability == 0 ? translate(context: context,text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,task),
                    //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,task),
                  ],
                  secondaryActions: <Widget>[
                    _buttonSliderAction(translate(context: context, text: 'working'),Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.045,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                    _buttonSliderAction(translate(context: context, text: 'ready'),Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.045,),colorSliderListo,WalkieTaskColors.white,4,task),
                  ],
                ),
              ),
            )
        );
      }
    }
    return listTaskRes;
  }

  void clickTarea(Tarea tarea) async {

    _deleteDataNewFirebase(tarea.id.toString());
    _deleteDataNewChat(tarea.id.toString());
    widget.blocAudioChangePage.inList.add({'page' : bottonSelect.opcion1});

    readTask(tarea);

    try{
      if(tarea.name.isEmpty){
        var result  = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => new AddNameTask(tareaRes: tarea,)));
        if(result){
          blocTaskReceived.inList.add(true);
        }
      }else{
        Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
            new ChatForTarea(
              tareaRes: tarea,
              listaCasosRes: widget.listaCasosRes,
              blocTaskSend: blocTaskReceived,
            )));
      }
    }catch(e){
      print(e.toString());
    }
  }

  Widget _buttonSliderAction(String titulo,Icon icono,Color color,Color colorText,int accion,Tarea tarea){
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
          if(tarea.is_priority_responsability == 0){tarea.is_priority_responsability = 1;}else{tarea.is_priority_responsability = 0;}
          tarea.updated_at = DateTime.now().toString();
          int result = await DatabaseProvider.db.updateTask(tarea);
          if(result == 1){
            blocTaskReceived.inList.add(true);
            try{
              await conexionHispanos.httpSendFavorite(tarea,tarea.is_priority_responsability);
            }catch(e){
              print(e.toString());
            }
            blocTaskReceived.inList.add(true);
          }
        }
        if(accion == 3){
          try{
            if(tarea.working == 0){
              showAlert(translate(context: context, text: 'TaskStarted'),WalkieTaskColors.color_89BD7D);
              tarea.working = 1;
              tarea.updated_at = DateTime.now().toString();
              if(await DatabaseProvider.db.updateTask(tarea) == 1){
                blocTaskReceived.inList.add(true);
                await conexionHispanos.httpTaskInit(tarea.id);
                updateData.actualizarListaRecibidos(blocTaskReceived, null);
              }
            }else{
              showAlert(translate(context: context, text: 'TaskAlreadyStarted'),WalkieTaskColors.color_89BD7D);
            }
          }catch(e){
            print(e.toString());
          }
          blocTaskReceived.inList.add(true);
        }
        if(accion == 4){
          if(tarea.working == 1 || tarea.working == 0){
            showAlert(translate(context: context, text: 'TaskFinished'),WalkieTaskColors.color_89BD7D);
            try{
              tarea.finalized = 1;
              tarea.updated_at = DateTime.now().toString();
              if(await DatabaseProvider.db.updateTask(tarea) == 1){
                blocTaskReceived.inList.add(true);
                await conexionHispanos.httpTaskFinalized(tarea.id);
                updateData.actualizarListaRecibidos(blocTaskReceived, null);
              }
            }catch(e){
              print(e.toString());
            }
            blocTaskReceived.inList.add(true);
          }else{
            showAlert('La tarea debe estar iniciada para finalizarla.',WalkieTaskColors.color_E07676);
          }
        }
      },
    );
  }

  Future<void> _updateMyItems(int oldIndex, int newIndex) async {
    print('oldIndex: $oldIndex -- newIndex: $newIndex');
    List<Tarea> auxList = new List<Tarea>();
    List<Tarea> listRecibidosRecorrer = listRecibidos.map((e) => e).toList();
    Tarea tareaOrder = listRecibidosRecorrer[oldIndex];
    listRecibidosRecorrer.removeAt(oldIndex);
    List<Tarea> listNew = [];
    try{
      if(newIndex == 0){
        auxList.add(tareaOrder);
      }

      bool entrar = false;
      if(listRecibidosRecorrer.length == newIndex){
        entrar = true;
      }

      for(int x = 0; x < listRecibidosRecorrer.length; x++){
        if(x == newIndex && newIndex != 0){
          auxList.add(tareaOrder);
        }
        if((x+1) == newIndex && entrar){
          auxList.add(tareaOrder);
        }
        auxList.add(listRecibidosRecorrer[x]);
      }
      if(newIndex > listRecibidosRecorrer.length){
        auxList.add(tareaOrder);
      }

      for(int x = 0; x < auxList.length; x++){
        listNew.add(auxList[x]);
      }
    }catch(e){
      print(e.toString());
    }

    List<String> listOrderFavorite = [];
    List<String> listOrderDate = [];
    listNew.forEach((element) {
      if(element != null && element.is_priority_responsability == 1){
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    listNew.forEach((element) {
      if(element != null && element.is_priority_responsability == 0){
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    await SharedPrefe().setStringListValue('listOrderRecived', listOrderFavorite);
    await SharedPrefe().setStringListValue('listOrderRecivedDate', listOrderDate);
    blocTaskReceived.inList.add(true);
  }

  Future<void> orderListRecived(List<Tarea> listTask) async {
    List listStringIdOrder = await SharedPrefe().getValue('listOrderRecived');
    List listStringIdOrderDate = await SharedPrefe().getValue('listOrderRecivedDate');
    Map<int,int> noEstanGuardarPosicion = {};

    if(listStringIdOrder == null || listStringIdOrderDate == null){
      listRecibidos = listTask;
      return;
    }

    Map<int,Tarea> tasksMap = {};

    for(int x = 0; x < listTask.length; x++){
      tasksMap[listTask[x].id] = listTask[x];
      bool entre = false;
      for(int xy = 0; xy < listStringIdOrder.length; xy++){
        if(listStringIdOrder[xy] == listTask[x].id.toString()){
          if(listStringIdOrderDate[xy] == listTask[x].updated_at){
            entre = true;
          }
        }
      }
      if(!entre){
        noEstanGuardarPosicion[listTask[x].id] = x;
      }
    }

    List<Tarea> listOrder = [];
    noEstanGuardarPosicion.forEach((key, value) {
      listOrder.add(tasksMap[key]);
    });

    for(int x = 0; x < listStringIdOrder.length; x++){
      if(noEstanGuardarPosicion[int.parse(listStringIdOrder[x])] == null){
        listOrder.add(tasksMap[int.parse(listStringIdOrder[x])]);
      }
    }

    List<String> listOrderFavorite = [];
    List<String> listOrderDate = [];
    List<Tarea> listDefinitive = [];
    listOrder.forEach((element) {
      if(element != null && element.is_priority_responsability == 1){
        listDefinitive.add(element);
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    listOrder.forEach((element) {
      if(element != null && element.is_priority_responsability == 0){
        listDefinitive.add(element);
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    await SharedPrefe().setStringListValue('listOrderRecived', listOrderFavorite);
    await SharedPrefe().setStringListValue('listOrderRecivedDate', listOrderDate);

    listRecibidos = listDefinitive;
    setState(() {});
  }

  void orderListTaskDeadLine(){
    List<Tarea> listAux = widget.listRecibidos;
    Map<int,Tarea> mapTaskAll = {};
    listAux.forEach((task) { mapTaskAll[task.id] = task;});
    listRecibidos = [];

    Map<String,List<int>> mapDiffDay = {};
    int pos = 0;
    double pos2 = 0;
    listAux.forEach((task) {
      if(task.deadline.isNotEmpty){
        Duration diff = DateTime.parse(task.deadline).difference(DateTime.now());
        if(mapDiffDay['${diff.inDays}'] == null){ mapDiffDay['${diff.inDays}'] = [];}
        mapDiffDay['${diff.inDays}'].add(task.id);
        if(diff.inDays > pos){ pos = diff.inDays;}
        if(diff.inDays < pos2){ pos2 = double.parse(diff.inDays.toString());}
      }else{
        if(mapDiffDay['vacio'] == null){ mapDiffDay['vacio'] = [];}
        mapDiffDay['vacio'].add(task.id);
      }
    });

    for(double x = pos2; x <= pos ; x++){
      if(mapDiffDay[x.toStringAsFixed(0)] != null){
        mapDiffDay[x.toStringAsFixed(0)].forEach((idTask) {
          listRecibidos.add(mapTaskAll[idTask]);
        });
      }
    }
    if(mapDiffDay['vacio'] != null){
      mapDiffDay['vacio'].forEach((idTask) {
        listRecibidos.add(mapTaskAll[idTask]);
      });
    }
    setState(() {});
  }

  Future<void> listenerAudio() async {
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      print('Current player state: $s');
      if(AudioPlayerState.COMPLETED == s){
        taskReproduciendo = 0;
        setState(() {});
      }
    });
  }

  void _notificationListener(){
    widget.push.mensajes.listen((argumento) async {
      int counter = await SharedPrefe().getValue('unityLogin');
      if(counter == 1){
        if(argumento['table'] != null && argumento['table'].contains('tasks')) {
          String idDoc = argumento['idDoc'];
          bool isTask = argumento['table'].contains('tasks');

          if (isTask) {
            List listNew = await SharedPrefe().getValue('notiListTask');
            if (listNew == null) {
              listNew = [];
            }
            List<String> listTaskNew = [];
            listNew.forEach((idDoc) { listTaskNew.add(idDoc);});
            listTaskNew.add(idDoc);
            await SharedPrefe().setStringListValue('notiListTask', listTaskNew);
            _updateDataNewFirebase();
            updateData.actualizarListaRecibidos(blocTaskReceived, null);
            blocTaskReceived.inList.add(true);
          }
        }

        if(argumento['table'] != null && argumento['table'].contains('sms')){
          if(argumento['idDoc'] != null){
            try{
              await Future.delayed(Duration(seconds: 2));
              await _checkListChat();
            }catch(_){}
          }
        }
      }
    });
  }

  List listViewTaskNew = [];
  Future<void> _updateDataNewFirebase() async {
    try{
      listViewTaskNew = await SharedPrefe().getValue('notiListTask') ?? [];
      setState(() {});
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> _deleteDataNewFirebase(String id) async {
    List<String> list = [];
    try{
      listViewTaskNew = await SharedPrefe().getValue('notiListTask') ?? [];
      listViewTaskNew.forEach((element) {
        if(element != id){
          list.add(element);
        }
      });
      await SharedPrefe().setStringListValue('notiListTask', list);
      listViewTaskNew = list;
      setState(() {});
    }catch(e){
      print(e.toString());
    }
    setState(() {});
  }

  Future<void> _deleteDataNewChat(String id) async {
    try{
      List<dynamic> listTaskNew = await SharedPrefe().getValue('notiListChat');
      if (listTaskNew == null) {
        listTaskNew = [];
      }
      List<String> listTaskNewString = [];
      listTaskNew.forEach((element) {
        if(element != id){
          listTaskNewString.add(element);
        }
      });
      await SharedPrefe().setStringListValue('notiListChat', listTaskNewString);
      await _checkListChat();
    }catch(_){}
  }

  List listCheckChat = [];
  Future<void> _checkListChat() async {
    try{
      listCheckChat = await SharedPrefe().getValue('notiListChat') ?? [];
      setState(() {});
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> readTask(Tarea task) async {
    if(task.read == 0){
      task.read = 1;
      if(await DatabaseProvider.db.updateTask(task) == 1){
        blocTaskReceived.inList.add(true);
        try{
          await conexionHispanos.httpReadTask(task.id);
        }catch(_){}
      }
    }
  }
}