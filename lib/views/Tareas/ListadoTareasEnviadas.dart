import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Firebase/Notification/push_notifications_provider.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/format_deadline.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/switch_button.dart';
import 'package:walkietaskv2/utils/task_sound.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';
import 'package:walkietaskv2/views/Home/NavigatorBotton.dart';

class ListadoTareasEnviadas extends StatefulWidget {

  ListadoTareasEnviadas({this.push, @required this.blocAudioChangePage,
    this.listEnviadosRes,this.mapIdUserRes,this.blocTaskSendRes,this.listaCasosRes, this.myUserRes});
  final List<Tarea> listEnviadosRes;
  final Map<int,Usuario> mapIdUserRes;
  final BlocTask blocTaskSendRes;
  final List<Caso> listaCasosRes;
  final Usuario myUserRes;
  final PushProvider push;
  final BlocProgress blocAudioChangePage;

  @override
  _ListadoTareasState createState() => _ListadoTareasState();
}

class _ListadoTareasState extends State<ListadoTareasEnviadas> {

  Map<int,bool> mapAppBar = {0:true,1:false,2:false};
  bool valueSwitch = false;

  List<Tarea> listEnviados = [];
  Map<int,Usuario> mapIdUser;
  Map<int,Caso> mapCasos = {};
  Map<int,bool> openForUserTask = {};
  Map<int,bool> openForProyectTask = {0 : false};

  double alto = 0;
  double ancho = 0;

  BlocTask blocTaskSend;

  conexionHttp conexionHispanos = new conexionHttp();

  AudioPlayer audioPlayer;
  int taskReproduciendo = 0;

  TextStyle textStylePrimary = TextStyle();
  TextStyle textStylePrimaryBold = TextStyle();
  TextStyle textStyleProject = TextStyle();
  TextStyle textStyleNotTitle = TextStyle();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blocTaskSend = widget.blocTaskSendRes;
    widget.listaCasosRes.forEach((element) { mapCasos[element.id] = element;});
    audioPlayer = new AudioPlayer();
    listenerAudio();
    _inicializar();
    _inicializar2();
    _inicializar3();
    _inicializarShared();
    _notificationListener();
  }

  void _inicializar(){
    mapIdUser = widget.mapIdUserRes;
    if(valueSwitch){
      orderListTaskDeadLine();
    }else{
      listEnviados = widget.listEnviadosRes;
      //orderListRecived(widget.listEnviadosRes);
    }
  }

  void _inicializar2(){
    if(widget.mapIdUserRes != null){
      mapIdUser.forEach((key, value) {
        openForUserTask[key] = false;
      });
    }
    setState(() {});
  }

  void _inicializar3() {
    if(widget.listaCasosRes.isNotEmpty){
      mapCasos.forEach((key, value) {
        openForProyectTask[key] = false;
      });
    }
    setState(() {});
  }

  Future<void> _inicializarShared() async {
    valueSwitch = await SharedPrefe().getValue('walkietaskFilterDate') ?? false;
    setState(() {});
    _updateDataNewFirebase();
    _checkListChat();
  }

  @override
  void dispose() {
    super.dispose();
    try{
      audioPlayer?.stop();
    }catch(_){}
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
      backgroundColor: Colors.white,
      body: _contenido(),
    );
  }

  Widget _appBArMenu(){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05, top: alto * 0.007,),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _appBArMenuText('ULTIMAS',0),
          ),
          Expanded(
            child: _appBArMenuText('USUARIO',1),
          ),
          Expanded(
            child: _appBArMenuText('PROYECTOS',2),
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
        if(index == 0){ _inicializarShared(); }
        if(index == 1){ valueSwitch = false; }
        if(index == 2){ valueSwitch = false; }
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
          listEnviados.isEmpty ?
          Container(
            width: ancho,
            height: alto * 0.8,
            child: Center(
              child: Cargando('Actualizando tareas.',context),
            ),
          ) :SingleChildScrollView(
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
                await SharedPrefe().setBoolValue('walkietaskFilterDate',val);
                setState(() {
                  valueSwitch = !valueSwitch;
                });
              },
              colorBgOff: WalkieTaskColors.grey,
              colorBgOn: WalkieTaskColors.primary,
              sizeCircule: alto * 0.025,
            ),
          ),
          Text('Fecha de entrega', style: WalkieTaskStyles().styleHelveticaneueRegular(color: WalkieTaskColors.primary, size: alto * 0.018, fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

  Widget _listado(){
    double h = alto > 600 ? alto * 0.74 : alto * 0.7;
    return Container(
      height: h,
      child: ReorderableListView(
        children: List.generate(listEnviados.length, (index) {
          Tarea tarea = listEnviados[index];
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
              child: _tareas(tarea, tarea.is_priority != 0),
              actions: <Widget>[
                _buttonSliderAction(tarea.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.04,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,tarea),
                //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
              ],
              secondaryActions: <Widget>[
                //_buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: 30,),colorSliderTrabajando,WalkieTaskColors.white,3,tarea),
                _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: 30,),colorSliderListo,WalkieTaskColors.white,4,tarea),
              ],
            ),
          );
        }),
        onReorder: (int oldIndex, int newIndex) {
          _updateMyItems(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _tareas(Tarea tarea, bool favorite,){

    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(mapIdUser[tarea.user_responsability_id] != null && mapIdUser[tarea.user_responsability_id].avatar != ''){
        avatarUser = Image.network(mapIdUser[tarea.user_responsability_id].avatar);
      }
    }

    bool working = tarea.working == 1;

    String daysLeft = getDayDiff(tarea.deadline);

    String proyectName = '(Sin proyecto asignado)';
    if(tarea.project_id != null && tarea.project_id != 0 && mapCasos[tarea.project_id] != null){
      proyectName = mapCasos[tarea.project_id].name;
    }

    String nameUser = '';
    if(mapIdUser[tarea.user_responsability_id] != null){
      nameUser = '${mapIdUser[tarea.user_responsability_id].name} ${mapIdUser[tarea.user_responsability_id].surname}';
      if(widget.myUserRes.id == mapIdUser[tarea.user_responsability_id].id){
        nameUser = 'Recordatorio personal';
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

    return InkWell(
      onTap: () =>clickTarea(tarea),
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
                      child: CircleAvatar(
                        radius: alto * 0.03,
                        backgroundImage: avatarUser.image,
                        //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                      ),
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
                    Text(tarea.name.isNotEmpty ? tarea.name : 'Tarea sin título. Tap para nombrarla',
                      style: tarea.name.isNotEmpty ? (activity ? textStylePrimaryBold : textStylePrimary) : textStyleNotTitle,),
                    Text(proyectName,style: textStyleProject,),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: ancho * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(daysLeft.replaceAll('-', ''),style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: daysLeft.contains('-') ? WalkieTaskColors.color_E07676 : Colors.grey[600]),),
                  SizedBox(height: alto * 0.006,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      chatCont != 0 ? Container(
                        margin: EdgeInsets.only(right: ancho * 0.002),
                        child: CircleAvatar(
                          backgroundColor: WalkieTaskColors.primary,
                          // 100 alto * 0.018, / 10 alto * 0.014, / 1 alto * 0.012,
                          radius: alto * radiusChat,
                          child: Text('$chatCont',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                        ),
                      ) : Container(),
                      tarea.url_audio.isNotEmpty ?
                      SoundTask(
                        alto: alto * 0.03,
                        colorStop: WalkieTaskColors.color_E07676,
                        path: tarea.url_audio,
                        idTask: tarea.id,
                        blocAudioChangePage: widget.blocAudioChangePage,
                        page: bottonSelect.opcion3,
                      ) : Container(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listadoUser(){
    Map<int,List<Tarea>> mapTask = {};
    listEnviados.forEach((element) {
      if(mapTask[element.user_responsability_id] == null){ mapTask[element.user_responsability_id] = [];}
      mapTask[element.user_responsability_id].add(element);
    });

    double h = alto > 600 ? alto * 0.8 : alto * 0.75;

    return Container(
      width: ancho,
      height: h,
      child: ListView.builder(
        itemCount: mapTask.length,
        itemBuilder: (context, index){
          List<Tarea> listTask = mapTask[mapTask.keys.elementAt(index)];
          Usuario user = mapIdUser[listTask[0].user_responsability_id];
          return user == null ?
          Container()
          :
          _tareasUser(user , listTask);
        },
      ),
    );
  }

  Widget _tareasUser(Usuario user, List<Tarea> listTask){

    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(user != null && user.avatar != ''){
        avatarUser = Image.network(user.avatar);
      }
    }

    List<Widget> listTaskWidget = listTaskGet(user, listTask);

    int cantTask = 0;
    listTask.forEach((element) {  if(element.finalized == 0){ cantTask++; } });

    String nameUser = '${user.name} ${user.surname}';
    if(widget.myUserRes.id == user.id){
      nameUser = 'Recordatorio personal';
    }

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
                    child: CircleAvatar(
                      radius: alto * 0.03,
                      backgroundImage: avatarUser.image,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: ancho * 0.03,right: ancho * 0.03,),
                      child: Text('$nameUser',
                          style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_76ADE3)),
                    ),
                  ),
                  Container(
                    child: Text('($cantTask ${cantTask < 1 ? 'tarea' : 'Tareas'})',
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

        bool working = task.working == 1;
        bool favorite = task.is_priority == 1;

        String proyectName = '(Sin proyecto asignado)';
        if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
          proyectName = mapCasos[task.project_id].name;
        }

        String daysLeft = getDayDiff(task.deadline);

        bool reproTask = false;
        if(taskReproduciendo == task.id){
          reproTask = true;
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
                    _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.03,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,task),
                    //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                  ],
                  secondaryActions: <Widget>[
                    //_buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.03,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                    _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.03,),colorSliderListo,WalkieTaskColors.white,4,task),
                  ],
                  child: InkWell(
                    onTap: () =>clickTarea(task),
                    child: Container(
                        width: ancho,
                        padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.04),
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
                                    Text(task.name.isEmpty ? 'Nombre no asignado' : task.name,
                                        style: textStylePrimaryBold),
                                    Text(proyectName,
                                      style: textStylePrimary,),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: ancho * 0.03, left: ancho * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(daysLeft.replaceAll('-', ''),style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: daysLeft.contains('-') ? WalkieTaskColors.color_E07676 : Colors.grey[600]),),
                                  SizedBox(height: alto * 0.006,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      chatCont != 0 ? Container(
                                        margin: EdgeInsets.only(right: ancho * 0.002),
                                        child: CircleAvatar(
                                          backgroundColor: WalkieTaskColors.primary,
                                          // 100 alto * 0.018, / 10 alto * 0.014, / 1 alto * 0.012,
                                          radius: alto * radiusChat,
                                          child: Text('$chatCont',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                                        ),
                                      ) : Container(),
                                      InkWell(
                                        child: task.url_audio != '' ? Icon(Icons.volume_up,color: reproTask ? WalkieTaskColors.color_89BD7D : Colors.grey[600],size: alto * 0.03,) : Container(),
                                        onTap: (){
                                          audioPlayer.play(task.url_audio);
                                          setState(() {
                                            taskReproduciendo = task.id;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
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
    listEnviados.forEach((element) {
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

    String nameProyect = proyect == null ? 'Sin proyecto asignado' : proyect.name;
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
                    child: Text('($cantTask ${cantTask < 1 ? 'tarea' : 'Tareas'})',
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
                  child: _tareas(task, task.is_priority != 0),
                  actions: <Widget>[
                    _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,task),
                    //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,task),
                  ],
                  secondaryActions: <Widget>[
                    _buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: 30,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                    _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: 30,),colorSliderListo,WalkieTaskColors.white,4,task),
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

    try{
      if(tarea.name.isEmpty){
      var result  = await Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new AddNameTask(tareaRes: tarea,)));
      if(result){
        blocTaskSend.inList.add(true);
      }
      }else{
        Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
            new ChatForTarea(
              tareaRes: tarea,
              listaCasosRes: widget.listaCasosRes,
              blocTaskSend: blocTaskSend,
            )));
      }
    }catch(e){
      print(e.toString());
    }
  }

  conexionHttp connectionHttp = new conexionHttp();

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
          //CAMBIAR ESTADO DE DESTACAR 0 = FALSE, 1 = TRUE
          if(tarea.is_priority == 0){ tarea.is_priority = 1;}else{tarea.is_priority = 0;}
          tarea.updated_at = DateTime.now().toString();
          //GUARDAR LOCALMENTE
          if(await DatabaseProvider.db.updateTask(tarea) == 1){
            //AVISAR A PATRONBLOC DE TAREAS ENVIADAS PARA QUE SE ACTUALICE
            blocTaskSend.inList.add(true);
            //ENVIAR A API
            try{
              await conexionHispanos.httpSendFavorite(tarea,tarea.is_priority);
            }catch(e){
              //SI NO HAY CONEXION GUARDAR EN TABLA LOCAL
            }
            blocTaskSend.inList.add(true);
          }
        }
        if(accion == 3){
          try{
            if(tarea.working == 0){
              showAlert('Tarea iniciada',WalkieTaskColors.color_89BD7D);
              tarea.working = 1;
              tarea.updated_at = DateTime.now().toString();
              if(await DatabaseProvider.db.updateTask(tarea) == 1){
                blocTaskSend.inList.add(true);
                await conexionHispanos.httpTaskInit(tarea.id);
              }
            }else{
              showAlert('Tarea ya se encuentra iniciada',WalkieTaskColors.color_89BD7D);
            }
          }catch(e){
            print(e.toString());
          }
          blocTaskSend.inList.add(true);
        }
        if(accion == 4){
          showAlert('Tarea finalizada',WalkieTaskColors.color_89BD7D);
          try{
            tarea.finalized = 1;
            tarea.updated_at = DateTime.now().toString();
            if(await DatabaseProvider.db.updateTask(tarea) == 1){
              blocTaskSend.inList.add(true);
              await conexionHispanos.httpTaskFinalized(tarea.id);
            }
          }catch(e){
            print(e.toString());
          }
          blocTaskSend.inList.add(true);
        }
      },
    );
  }

  Future<void> _updateMyItems(int oldIndex, int newIndex) async {
    print('oldIndex: $oldIndex -- newIndex: $newIndex');
    List<Tarea> auxList = new List<Tarea>();
    List<Tarea> listRecibidosRecorrer = listEnviados.map((e) => e).toList();
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
      if(element != null && element.is_priority == 1){
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    listNew.forEach((element) {
      if(element != null && element.is_priority == 0){
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    await SharedPrefe().setStringListValue('listOrderSend', listOrderFavorite);
    await SharedPrefe().setStringListValue('listOrderSendDate', listOrderDate);
    blocTaskSend.inList.add(true);
  }

  void orderListTaskDeadLine(){
    List<Tarea> listAux = widget.listEnviadosRes;
    Map<int,Tarea> mapTaskAll = {};
    listAux.forEach((task) { mapTaskAll[task.id] = task;});
    listEnviados = [];

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
          listEnviados.add(mapTaskAll[idTask]);
        });
      }
    }
    if(mapDiffDay['vacio'] != null){
      mapDiffDay['vacio'].forEach((idTask) {
        listEnviados.add(mapTaskAll[idTask]);
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
    }catch(e){
      print(e.toString());
    }
    if(mounted){
      setState(() {});
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
      blocTaskSend.inList.add(true);
      setState(() {});
    }catch(e){
      print(e.toString());
    }
  }
}