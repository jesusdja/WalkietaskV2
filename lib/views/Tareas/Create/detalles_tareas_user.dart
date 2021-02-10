import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/format_deadline.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/task_sound.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/Create/detalles_tareas_user_bottom.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';
import 'package:walkietaskv2/views/Home/NavigatorBotton.dart';

class DetailsTasksForUser extends StatefulWidget {

  final bool isPersonal;
  final Usuario user;
  final Map<int,List> mapDataUserHome;
  final List<Caso> listaCasos;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;
  final BlocProgress blocIndicatorProgress;
  final UpdateData updateData;
  final BlocProgress blocAudioChangePage;

  DetailsTasksForUser({
    @required this.user,
    @required this.isPersonal,
    @required this.mapDataUserHome,
    @required this.listaCasos,
    @required this.blocTaskReceived,
    @required this.blocTaskSend,
    @required this.blocIndicatorProgress,
    @required this.updateData,
    @required this.blocAudioChangePage,
  });

  @override
  _DetailsTasksForUserState createState() => _DetailsTasksForUserState();
}

class _DetailsTasksForUserState extends State<DetailsTasksForUser> {

  double alto = 0;
  double ancho = 0;
  double progressIndicator = 0;

  int cant = 0;

  TextStyle textStylePrimary;
  TextStyle textStylePrimaryBold;
  TextStyle textStyleBlue;
  TextStyle textStyleBlueLitle;
  TextStyle textStylePrimaryLitle;
  TextStyle textStylePrimaryLitleRed;
  TextStyle textStylePrimaryTextCenter;

  bool isPersonal = false;
  bool viewIndicatorProgress = false;
  bool tagReceived = true;

  Usuario user;

  Map<int,List> mapDataUserHome;
  Map<int,Caso> mapCasos = {};
  List<Tarea> listRecived = [];
  List<Tarea> listSend = [];


  StreamSubscription streamSubscriptionTaskSend;
  StreamSubscription streamSubscriptionTaskRecived;
  StreamSubscription streamSubscriptionProgress;

  conexionHttp conexionHispanos = new conexionHttp();

  @override
  void initState() {
    super.initState();
    isPersonal = widget.isPersonal;
    user = widget.user;
    mapDataUserHome = widget.mapDataUserHome;

    widget.listaCasos.forEach((element) { mapCasos[element.id] = element;});

    if(mapDataUserHome[user.id] != null && mapDataUserHome[user.id][1] != null){
      mapDataUserHome[user.id][1].forEach((element) { listRecived.add(element); });
    }
    if(mapDataUserHome[user.id] != null && mapDataUserHome[user.id][2] != null){
      mapDataUserHome[user.id][2].forEach((element) { listSend.add(element); });
    }

    _updateDataNewFirebase();

    _inicializarPatronBlocTaskSend();
    _inicializarPatronBlocTaskRecived();
    _inicializarPatronBlocProgress();

    addPop(1);
  }

  @override
  void dispose() {
    super.dispose();
    try{
      streamSubscriptionTaskSend?.cancel();
      streamSubscriptionTaskRecived?.cancel();
      streamSubscriptionProgress?.cancel();
    }catch(e){
      print(e.toString());
    }
  }

  addPop(int num) async{
    await addPopTask(num);
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022, color: WalkieTaskColors.black, spacing: 1);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.022, color: WalkieTaskColors.black, spacing: 0.5);
    textStyleBlue = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.024, color: WalkieTaskColors.primary, spacing: 1, fontWeight: FontWeight.bold);
    textStyleBlueLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.primary, spacing: 0.5, fontWeight: FontWeight.bold);
    textStylePrimaryLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: WalkieTaskColors.black, spacing: 1);
    textStylePrimaryLitleRed = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: WalkieTaskColors.color_DD7777, spacing: 1);
    textStylePrimaryTextCenter = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.022, color: WalkieTaskColors.black, spacing: 0.5);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: WalkieTaskColors.white,
        appBar: _appBar(),
        bottomNavigationBar: BottomDetailsTask(
          user: user,
          isPersonal: isPersonal,
          listaCasos: widget.listaCasos,
          blocIndicatorProgress: widget.blocIndicatorProgress,
          blocTaskReceived: widget.blocTaskReceived,
          blocTaskSend: widget.blocTaskSend,
          updateData: widget.updateData,
        ),
        body: _body(),
      ),
    );
  }

  Widget _body(){

    double h = alto < 600 ? alto * 0.32 : alto * 0.34;
    double h2 = alto < 600 ? alto * 0.72 : alto * 0.75;

    return Container(
      width: ancho,
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            isPersonal ? Container() :
            Container(
              width: ancho,
              child: Row(
                children: [
                  tag(0, containReceived),
                  tag(1, containSend),
                ],
              ),
            ),
            isPersonal ? Container() :
            Container(
              height: h2,
              width: ancho,
              color: WalkieTaskColors.white,
              child: tagReceived ? _listTaskRecived() : _listTaskSend(),
            ),
            isPersonal ? Container(
              width: ancho,
              height: alto * 0.06,
              color: WalkieTaskColors.white,
              child: Container(
                margin: EdgeInsets.only(top: alto * 0.02, left: ancho * 0.03),
                child: Text('Mis Recordatorios', style: textStylePrimaryBold,),
              ),
            ) : Container(),
            isPersonal ? Container(
              width: ancho,
              color: WalkieTaskColors.white,
              height: h2,
              //color: Colors.grey,
              child: _listTaskPersonal(h),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Widget tag(int type, bool viewCircule ){
    String name = 'Recibidas';
    bool activo = tagReceived;
     if(type == 1){
      name = 'Enviadas';
      activo = !tagReceived;
      viewCircule = containSend;
    }

    TextStyle style = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.021, color: WalkieTaskColors.white, spacing: 0.5);
    TextStyle style2 = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.021, color: WalkieTaskColors.color_969696, spacing: 0.5);

    return Expanded(
      child: InkWell(
        onTap: (){
          if(type == 0){
            tagReceived = true;
            containReceived = false;
          }else{
            tagReceived = false;
            containSend = false;
          }
          setState(() {});
        },
        child: Container(
          padding: EdgeInsets.all(alto * 0.012),
          color: activo ? WalkieTaskColors.primary : WalkieTaskColors.white,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !viewCircule ? Container() : Icon(Icons.circle, size: alto * 0.012,color: !activo ? WalkieTaskColors.primary : WalkieTaskColors.white,),
                SizedBox(width: ancho * 0.01,),
                Text(name, textAlign: TextAlign.center, style: activo ? style : style2,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listTaskRecived(){
    List<Widget> data = [
      SizedBox(height: alto * 0.02,)
    ];
    listRecived.forEach((task) {
      if(task.finalized != 1){
        bool isNew = false;
        int cantChat = 0;
        listViewTaskNew.forEach((element) {
          if(element == task.id.toString()){
            isNew = true;
          }
        });
        listViewTaskNewChat.forEach((element) {
          if(element == task.id.toString()){
            isNew = true;
            cantChat++;
          }
        });

        double radiusChat = 0.012;
        if(cantChat >= 10 && cantChat < 100){radiusChat = 0.014; }
        if(cantChat > 100){radiusChat = 0.018; }

        String daysLeft = getDayDiff(task.deadline);

        String nameCase = '(Sin proyecto asignado)';
        if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
          nameCase = mapCasos[task.project_id].name;
        }

        data.add(
            IntrinsicHeight(
              child: Container(
                key: ValueKey("value${task.id}"),
                color: Colors.white,
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: InkWell(
                    onTap: () => clickTarea(task, true),
                    child: Container(

                      width: ancho,
                      child: Row(
                        children: [
                          task.working == 1 ? Container(
                            width: ancho * 0.015,
                            color: WalkieTaskColors.color_89BD7D,
                          ) : Container(width: ancho * 0.015,),
                          Container(
                            width: ancho * 0.06,
                            padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                            child: Column(
                              children: [
                                daysLeft.contains('-') ?
                                Container(
                                  padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                                  height: alto * 0.02,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ) : Container(),
                                task.is_priority_responsability == 1 ?
                                Container(
                                  margin: EdgeInsets.only(right: ancho * 0.02),
                                  child: Icon(Icons.star,color: WalkieTaskColors.yellow, size: alto * 0.03,),
                                ) : Container(),

                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.name.isNotEmpty ? task.name : 'Tarea sin título. Tap para nombrarla', style: task.name.isEmpty ? textStyleBlue : isNew ? textStylePrimaryBold : textStylePrimary),
                                  Text(nameCase, style: textStylePrimaryLitle,)
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                            width: ancho * 0.2,
                            margin: EdgeInsets.only(right: ancho * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      cantChat != 0 ? Container(
                                        margin: EdgeInsets.only(right: ancho * 0.02),
                                        child: CircleAvatar(
                                          backgroundColor: WalkieTaskColors.primary,
                                          // 100 alto * 0.018, / 10 alto * 0.014, / 1 alto * 0.012,
                                          radius: alto * radiusChat,
                                          child: Text('$cantChat',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                                        ),
                                      ) : Container(),
                                      daysLeft.isEmpty ? Container() : Text(daysLeft.replaceAll('-', ''), style: daysLeft.contains('-') ? textStylePrimaryLitleRed : textStylePrimaryLitle,),
                                    ],
                                  ),
                                ),
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
                  actions: <Widget>[
                    _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.04,), WalkieTaskColors.yellow, WalkieTaskColors.white,1,task, true),
                    //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                  ],
                  secondaryActions: <Widget>[
                    _buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderTrabajando,WalkieTaskColors.white,3,task, true),
                    _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderListo,WalkieTaskColors.white,4,task, true),
                  ],
                ),
              ),
            )
        );
        data.add(Divider());
      }
    });

    int cont = 0;
    listRecived.forEach((element) {
      if(element.finalized != 1){ cont++; }
    });

    return Container(
      width: ancho,
      child: (cont < 1 || listRecived.isEmpty) ?
      Container(
        margin: EdgeInsets.only(top: alto * 0.15),
        width: ancho,
        child: Text('No has recibido tareas de ${user.name}', style: textStylePrimaryTextCenter, textAlign: TextAlign.center,),
      ) :
      Container(
        width: ancho,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: data,
          ),
        ),
      ),
    );
  }

  Widget _listTaskSend(){
    List<Widget> data = [
      SizedBox(height: alto * 0.02,)
    ];
    listSend.forEach((task) {
      if(task.finalized != 1){
        String daysLeft = getDayDiff(task.deadline);

        String nameCase = '(Sin proyecto asignado)';
        if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
          nameCase = mapCasos[task.project_id].name;
        }

        bool isNew = false;
        int cantChat = 0;
        listViewTaskNew.forEach((element) {
          if(element == task.id.toString()){
            isNew = true;
          }
        });
        listViewTaskNewChat.forEach((element) {
          if(element == task.id.toString()){
            isNew = true;
            cantChat++;
          }
        });

        double radiusChat = 0.012;
        if(cantChat >= 10 && cantChat < 100){radiusChat = 0.014; }
        if(cantChat > 100){radiusChat = 0.018; }

        data.add(
            IntrinsicHeight(
              child: Container(
                key: ValueKey("value${task.id}"),
                color: Colors.white,
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: InkWell(
                    onTap: () => clickTarea(task, false),
                    child: Container(
                      width: ancho,
                      child: Row(
                        children: [
                          task.working == 1 ? Container(
                            width: ancho * 0.015,
                            color: WalkieTaskColors.color_89BD7D,
                          ) : Container(width: ancho * 0.015,),
                          Container(
                            width: ancho * 0.06,
                            padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                            child: Column(
                              children: [
                                daysLeft.contains('-') ?
                                Container(
                                  padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                                  height: alto * 0.02,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ) : Container(),
                                task.is_priority == 1 ?
                                Container(
                                  margin: EdgeInsets.only(right: ancho * 0.02),
                                  child: Icon(Icons.star,color: WalkieTaskColors.yellow, size: alto * 0.03,),
                                ) : Container(),

                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.name.isNotEmpty ? task.name : 'Tarea sin título. Tap para nombrarla', style: task.name.isEmpty ? textStyleBlue : isNew ? textStylePrimaryBold : textStylePrimary),
                                  Text(nameCase, style: textStylePrimaryLitle,)
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                            width: ancho * 0.2,
                            margin: EdgeInsets.only(right: ancho * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      cantChat != 0 ? Container(
                                        margin: EdgeInsets.only(right: ancho * 0.02),
                                        child: CircleAvatar(
                                          backgroundColor: WalkieTaskColors.primary,
                                          // 100 alto * 0.018, / 10 alto * 0.014, / 1 alto * 0.012,
                                          radius: alto * radiusChat,
                                          child: Text('$cantChat',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                                        ),
                                      ) : Container(),
                                      daysLeft.isEmpty ? Container() : Text(daysLeft.replaceAll('-', ''), style: daysLeft.contains('-') ? textStylePrimaryLitleRed : textStylePrimaryLitle,),
                                    ],
                                  ),
                                ),
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
                  actions: <Widget>[
                    _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.04,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,task, false),
                    //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                  ],
                  secondaryActions: <Widget>[
                    //_buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                    _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderListo,WalkieTaskColors.white,4,task, false),
                  ],
                ),
              ),
            )
        );
        data.add(Divider());
      }
    });

    int cont = 0;
    listSend.forEach((element) {
      if(element.finalized != 1){ cont++; }
    });

    return Container(
      width: ancho,
      child: (cont < 1 || listSend.isEmpty) ?
      Container(
        margin: EdgeInsets.only(top: alto * 0.15),
        width: ancho,
        child: Text('No has enviado tareas a ${user.name}', style: textStylePrimaryTextCenter, textAlign: TextAlign.center,),
      ) :
      Container(
        width: ancho,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: data,
          ),
        ),
      ),
    );
  }

  Widget _listTaskPersonal(double he){
    List<Widget> data = [];
    listRecived.forEach((task) {
      if(task.finalized != 1){
        String daysLeft = getDayDiff(task.deadline);

        String nameCase = '(Sin proyecto asignado)';
        if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
          nameCase = mapCasos[task.project_id].name;
        }

        data.add(
          IntrinsicHeight(
            child: Container(
              key: ValueKey("value${task.id}"),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: InkWell(
                  onTap: () => clickTarea(task, true),
                  child: Container(
                    width: ancho,
                    child: Row(
                      children: [
                        task.working == 1 ? Container(
                          width: ancho * 0.015,
                          color: WalkieTaskColors.color_89BD7D,
                        ) : Container(width: ancho * 0.015,),
                        Container(
                          padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                          width: ancho * 0.06,
                          child: Column(
                            children: [
                              daysLeft.contains('-') ?
                              Container(
                                padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                                height: alto * 0.02,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ) : Container(),
                              task.is_priority_responsability == 1 ?
                              Container(
                                margin: EdgeInsets.only(right: ancho * 0.02),
                                child: Icon(Icons.star,color: WalkieTaskColors.yellow, size: alto * 0.03,),
                              ) : Container(),

                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.name.isNotEmpty ? task.name : 'Tarea sin título. Tap para nombrarla', style: task.name.isEmpty ? textStyleBlue :textStylePrimary),
                                Text(nameCase, style: textStylePrimaryLitle,)
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: ancho * 0.2,
                          padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                          margin: EdgeInsets.only(right: ancho * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(daysLeft.replaceAll('-', ''), style: daysLeft.contains('-') ? textStylePrimaryLitleRed : textStylePrimaryLitle,),
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
                actions: <Widget>[
                  _buttonSliderAction(task.is_priority_responsability == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.04,), WalkieTaskColors.yellow, WalkieTaskColors.white,1,task, true),
                  //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  _buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderTrabajando,WalkieTaskColors.white,3,task, true),
                  _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderListo,WalkieTaskColors.white,4,task, true),
                ],
              ),
            ),
          ),
        );
        data.add(Divider());
      }
    });


    return Container(
      width: ancho,
      child: listRecived.isEmpty ?
      Container(
        margin: EdgeInsets.only(top: alto * 0.02),
        width: ancho,
        child: Text('Sin recordatorio personal', style: textStylePrimary, textAlign: TextAlign.center,),
      ) :
      Container(
        width: ancho,
        height: he * 2.1,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: data,
          ),
        ),
      ),
    );
  }

  AppBar _appBar(){

    Image avatarUser = Image.network(avatarImage);
    if(user.avatar.isNotEmpty){
      avatarUser = Image.network('$directorioImage${user.avatar}');
    }

    return AppBar(
      backgroundColor: Colors.grey[100],
      titleSpacing: 0,
      elevation: 0.0,
      title: Container(
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: ancho * 0.015),
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      decoration: new BoxDecoration(
                        color: bordeCirculeAvatar, // border color
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: alto * 0.02,
                        backgroundImage: avatarUser.image,
                        //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(isPersonal ? 'Recordatorio personal' : user.name, style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.025, color: WalkieTaskColors.black, spacing: 0.5, ),)
          ],
        ),
      ),
      leading: InkWell(
        onTap: () {
          widget.blocAudioChangePage.inList.add({'page' : bottonSelect.opcion1});
          addPop((-1));
          Navigator.of(context).pop();
        },
        child: Container(
          child: Icon(Icons.arrow_back_ios, size: alto * 0.035, color: WalkieTaskColors.primary,),
        ),
      ),
      bottom: _indicatorProgress(),
    );
  }

  void clickTarea(Tarea tarea, isReceived) async {

    _deleteDataNewFirebase(tarea.id.toString());
    _deleteDataNewChat(tarea.id.toString());

    if(isReceived){
      readTask(tarea);
    }

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
              listaCasosRes: widget.listaCasos,
              blocTaskSend: widget.blocTaskReceived,
            )));
      }
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> readTask(Tarea task) async {

    //CAMBIAR ESTADO DE DESTACAR 0 = FALSE, 1 = TRUE
    if(task.read == 0){
      task.read = 1;
      if(await DatabaseProvider.db.updateTask(task) == 1){
        widget.blocTaskReceived.inList.add(true);
        try{
          await conexionHispanos.httpReadTask(task.id);
        }catch(_){}
      }
    }
  }

  _inicializarPatronBlocTaskSend(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionTaskSend = widget.blocTaskSend.outList.listen((newVal) {
        if(newVal){
          _updateTask();
        }
      });
    } catch (e) {}
  }
  _inicializarPatronBlocTaskRecived(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionTaskRecived = widget.blocTaskReceived.outList.listen((newVal) {
        if(newVal){
          _updateTask();
        }
      });
    } catch (e) {}
  }

  _updateTask() async {
    List<Tarea> newListSend = await DatabaseProvider.db.getAllSendTask();
    List<Tarea> newListRecived = await DatabaseProvider.db.getAllRecevidTask();
    Map<int,List> mapList = _dataToMapDataUserHome(newListRecived, newListSend);
    if(mapList[user.id] != null && mapList[user.id][1] != null){
      List<Tarea> new1 = [];
      mapList[user.id][1].forEach((element) { new1.add(element);});
      listRecived = new1;
    }
    if(mapList[user.id] != null && mapList[user.id][2] != null){
      List<Tarea> new2 = [];
      mapList[user.id][2].forEach((element) { new2.add(element);});
      listSend = new2;
    }
    setState(() {});
    _updateDataNewFirebase();
  }

  List<String> listViewTaskNew = [];
  List<String> listViewTaskNewChat = [];
  bool containReceived = false;
  bool containSend = false;
  Future<void> _updateDataNewFirebase() async {
    List listViewTaskNew2 = [];
    List listViewTaskNew3 = [];
    try{
      listViewTaskNew3 = await SharedPrefe().getValue('notiListTask') ?? [];
      listViewTaskNew = [];
      listViewTaskNew3.forEach((element) {
        listViewTaskNew.add(element);
        listRecived.forEach((task) { if(task.id.toString() == element){ containReceived = true;} });
        listSend.forEach((task) { if(task.id.toString() == element){ containSend = true;} });
      });
      listViewTaskNew2 = await SharedPrefe().getValue('notiListChat') ?? [];
      listViewTaskNewChat = [];
      listViewTaskNew2.forEach((element) {
        listViewTaskNewChat.add(element);
        listRecived.forEach((task) { if(task.id.toString() == element){ containReceived = true;} });
        listSend.forEach((task) { if(task.id.toString() == element){ containSend = true;} });
      });
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
      listViewTaskNewChat = listTaskNewString;
      setState(() {});
    }catch(_){}
  }

  Map<int,List> _dataToMapDataUserHome(List<Tarea> listRecibidos,List<Tarea> listEnviados, ){
    Map<int,List> data = {};
    try{
      listRecibidos.forEach((task) {
        if(data[task.user_id] == null){
          data[task.user_id] = ['',[],[]];
        }
        data[task.user_id][1].add(task);
        if(data[task.user_id][0] == ''){
          data[task.user_id][0] = task.deadline;
        }else{
          if(task.deadline.isEmpty || data[task.user_id][0].isEmpty){
            if(data[task.user_id][0].isEmpty){ data[task.user_id][0] = task.deadline.isEmpty; }
          }else{
            DateTime dateCreate = DateTime.parse(task.deadline);
            Duration difDays = dateCreate.difference(DateTime.now());

            DateTime dateCreate2 = DateTime.parse(data[task.user_id][0]);
            Duration difDays2 = dateCreate2.difference(DateTime.now());

            if(difDays < difDays2){
              data[task.user_id][0] = dateCreate2.toString();
            }
          }
        }
      });

      listEnviados.forEach((task) {
        if(data[task.user_responsability_id] == null){
          data[task.user_responsability_id] = ['',[],[]];
        }
        data[task.user_responsability_id][2].add(task);
        if(data[task.user_responsability_id][0] == ''){
          data[task.user_responsability_id][0] = task.deadline;
        }else{
          if(task.deadline.isEmpty || data[task.user_responsability_id][0].isEmpty){
            if(data[task.user_responsability_id][0].isEmpty){ data[task.user_responsability_id][0] = task.deadline.isEmpty; }
          }else{
            DateTime dateCreate = DateTime.parse(task.deadline);
            Duration difDays = dateCreate.difference(DateTime.now());

            DateTime dateCreate2 = DateTime.parse(data[task.user_responsability_id][0]);
            Duration difDays2 = dateCreate2.difference(DateTime.now());

            if(difDays < difDays2){
              data[task.user_responsability_id][0] = dateCreate2.toString();
            }
          }
        }
      });
    }catch(e){
      print('ERROR AL ORDENAR DATA DE HOME');
    }
    return data;
  }

  Widget _indicatorProgress(){

    String textCant = 'Enviando tarea...';
    if(cant > 1){
      textCant = 'Enviando tareas($cant)...';
    }

    return viewIndicatorProgress ? PreferredSize(
      preferredSize: Size.fromHeight(alto * 0.05),
      child: Container(
        color: colorfondoSelectUser,
        height: alto * 0.05,
        width: ancho,
        padding: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05),
        child: Row(
          children: <Widget>[
            Container(
              child: Text(textCant, style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.021, color: WalkieTaskColors.color_969696),),
            ),
            Expanded(
              child: Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  border: new Border.all(
                    width: 2,
                    color: WalkieTaskColors.primary,
                  ),
                ),
                child: LinearProgressIndicator(
                  backgroundColor: WalkieTaskColors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(WalkieTaskColors.primary),
                  value: progressIndicator,
                ),
              ),
            ),
          ],
        ),
      ),
    ) :
    PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Container()
    );
  }

  _inicializarPatronBlocProgress(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionProgress = widget.blocIndicatorProgress.outList.listen((newVal) {
        progressIndicator = double.parse('${newVal['progressIndicator']}');
        cant = int.parse('${newVal['cant']}');
        viewIndicatorProgress = newVal['viewIndicatorProgress'];
        if(progressIndicator == 1.0){
          widget.updateData.actualizarListaEnviados(widget.blocTaskSend, null);
        }
        setState(() {});
      });
    } catch (e) {}
  }

  Widget _buttonSliderAction(String titulo,Icon icono,Color color,Color colorText,int accion,Tarea tarea, bool isRecived){
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
            if(tarea.is_priority_responsability == 0){tarea.is_priority_responsability = 1;}else{tarea.is_priority_responsability = 0;}
          }else{
            if(tarea.is_priority == 0){tarea.is_priority = 1;}else{tarea.is_priority = 0;}
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
              await conexionHispanos.httpSendFavorite(tarea,tarea.is_priority);
            }catch(e){}
          }
        }
        if(accion == 3){
          try{
            if(tarea.working == 0){
              showAlert('Tarea iniciada',WalkieTaskColors.color_89BD7D);
              tarea.working = 1;
              if(await DatabaseProvider.db.updateTask(tarea) == 1){
                if(isRecived){
                  widget.blocTaskReceived.inList.add(true);
                }else{
                  widget.blocTaskSend.inList.add(true);
                }
                await conexionHispanos.httpTaskInit(tarea.id);
              }
            }else{
              showAlert('Tarea ya se encuentra iniciada',WalkieTaskColors.color_89BD7D);
            }
          }catch(e){
            print(e.toString());
          }
        }
        if(accion == 4){
          if(tarea.working == 1 || tarea.working == 0){
            showAlert('Tarea finalizada',WalkieTaskColors.color_89BD7D);
            try{
              tarea.finalized = 1;
              if(await DatabaseProvider.db.updateTask(tarea) == 1){
                if(isRecived){
                  widget.blocTaskReceived.inList.add(true);
                }else{
                  widget.blocTaskSend.inList.add(true);
                }
                await conexionHispanos.httpTaskFinalized(tarea.id);
                widget.updateData.actualizarListaRecibidos(widget.blocTaskReceived, null);
              }
            }catch(e){
              print(e.toString());
            }
          }else{
            showAlert('La tarea debe estar iniciada para finalizarla.',WalkieTaskColors.color_E07676);
          }
        }
      },
    );
  }
}
