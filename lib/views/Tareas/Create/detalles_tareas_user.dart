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
import 'package:walkietaskv2/utils/task_sound.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/Create/detalles_tareas_user_bottom.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';

class DetailsTasksForUser extends StatefulWidget {

  final bool isPersonal;
  final Usuario user;
  final Map<int,List> mapDataUserHome;
  final List<Caso> listaCasos;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;
  final BlocProgress blocIndicatorProgress;
  final UpdateData updateData;

  DetailsTasksForUser({
    @required this.user,
    @required this.isPersonal,
    @required this.mapDataUserHome,
    @required this.listaCasos,
    @required this.blocTaskReceived,
    @required this.blocTaskSend,
    @required this.blocIndicatorProgress,
    @required this.updateData,
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

  bool isPersonal = false;
  bool viewIndicatorProgress = false;

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

    _inicializarPatronBlocTaskSend();
    _inicializarPatronBlocTaskRecived();
    _inicializarPatronBlocProgress();
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

    return SingleChildScrollView(
      child: Container(
        width: ancho,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            isPersonal ? Container() : Container(
              width: ancho,
              height: alto * 0.06,
              //color: Colors.orange,
              child: Container(
                margin: EdgeInsets.only(top: alto * 0.02, left: ancho * 0.03),
                child: Text('Tareas recibidas', style: textStylePrimaryBold,),
              ),
            ),
            isPersonal ? Container() : Container(
              width: ancho,
              height: h,
              //color: Colors.red,
              child: _listTaskRecived(h),
            ),
            isPersonal ? Container() : Container(
              width: ancho,
              height: alto * 0.06,
              //color: Colors.blue,
              child: Container(
                margin: EdgeInsets.only(top: alto * 0.02, left: ancho * 0.03),
                child: Text('Tareas enviadas', style: textStylePrimaryBold,),
              ),
            ),
            isPersonal ? Container() : Container(
              width: ancho,
              height: h,
              //color: Colors.grey,
              child: _listTaskSend(h),
            ),
            isPersonal ? Container(
              width: ancho,
              height: alto * 0.06,
              //color: Colors.blue,
              child: Container(
                margin: EdgeInsets.only(top: alto * 0.02, left: ancho * 0.03),
                child: Text('Mis Recordatorios', style: textStylePrimaryBold,),
              ),
            ) : Container(),
            isPersonal ? Container(
              width: ancho,
              height: h * 2.1,
              //color: Colors.grey,
              child: _listTaskPersonal(h),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Widget _listTaskRecived(double h){
    List<Widget> data = [];
    listRecived.forEach((task) {

      String daysLeft = getDayDiff(task.deadline);

      String nameCase = '(Sin proyecto asignado)';
      if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
        nameCase = mapCasos[task.project_id].name;
      }

      data.add(
          InkWell(
            onTap: () => clickTarea(task),
            child: Container(
              key: ValueKey("value${task.id}"),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Container(
                  padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                  width: ancho,
                  child: Row(
                    children: [
                      Container(
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
                              child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                            ) : Container(),

                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.name.isNotEmpty ? task.name : 'Tarea sin título. Tap para nombrarla', style: task.name.isEmpty ? textStyleBlue :textStylePrimary),
                            Text(nameCase, style: textStylePrimaryLitle,)
                          ],
                        ),
                      ),
                      Container(
                        width: ancho * 0.2,
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
                            ) : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.04,),Colors.yellow[600],WalkieTaskColors.white,1,task),
                  //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  _buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                  _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderListo,WalkieTaskColors.white,4,task),
                ],
              ),
            ),
          )
      );
      data.add(Divider());
    });


    return Container(
      width: ancho,
      child: listRecived.isEmpty ?
      Container(
        margin: EdgeInsets.only(top: alto * 0.02),
        width: ancho,
        child: Text('No has recibido tareas de ${user.name}', style: textStylePrimary, textAlign: TextAlign.center,),
      ) :
      Container(
        width: ancho,
        height: h,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: data,
          ),
        ),
      ),
    );
  }

  Widget _listTaskSend(double h){
    List<Widget> data = [];
    listSend.forEach((task) {

      String daysLeft = getDayDiff(task.deadline);

      String nameCase = '(Sin proyecto asignado)';
      if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
        nameCase = mapCasos[task.project_id].name;
      }

      data.add(
          InkWell(
            onTap: () => clickTarea(task),
            child: Container(
              key: ValueKey("value${task.id}"),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Container(
                  padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                  width: ancho,
                  child: Row(
                    children: [
                      Container(
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
                            task.is_priority == 1 ?
                            Container(
                              margin: EdgeInsets.only(right: ancho * 0.02),
                              child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                            ) : Container(),

                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.name.isNotEmpty ? task.name : 'Tarea sin título. Tap para nombrarla', style: task.name.isEmpty ? textStyleBlue :textStylePrimary),
                            Text(nameCase, style: textStylePrimaryLitle,)
                          ],
                        ),
                      ),
                      Container(
                        width: ancho * 0.2,
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
                            ) : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.04,),Colors.yellow[600],WalkieTaskColors.white,1,task),
                  //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  //_buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                  //_buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderListo,WalkieTaskColors.white,4,task),
                ],
              ),
            ),
          )
      );
      data.add(Divider());
    });


    return Container(
      width: ancho,
      child: listSend.isEmpty ?
      Container(
        margin: EdgeInsets.only(top: alto * 0.02),
        width: ancho,
        child: Text('No has enviado tareas a ${user.name}', style: textStylePrimary, textAlign: TextAlign.center,),
      ) :
      Container(
        width: ancho,
        height: h,
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

      String daysLeft = getDayDiff(task.deadline);

      String nameCase = '(Sin proyecto asignado)';
      if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
        nameCase = mapCasos[task.project_id].name;
      }

      data.add(
          InkWell(
            onTap: () => clickTarea(task),
            child: Container(
              key: ValueKey("value${task.id}"),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Container(
                  padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
                  width: ancho,
                  child: Row(
                    children: [
                      Container(
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
                            task.is_priority == 1 ?
                            Container(
                              margin: EdgeInsets.only(right: ancho * 0.02),
                              child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                            ) : Container(),

                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.name.isNotEmpty ? task.name : 'Tarea sin título. Tap para nombrarla', style: task.name.isEmpty ? textStyleBlue :textStylePrimary),
                            Text(nameCase, style: textStylePrimaryLitle,)
                          ],
                        ),
                      ),
                      Container(
                        width: ancho * 0.2,
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
                            ) : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.04,),Colors.yellow[600],WalkieTaskColors.white,1,task),
                  //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  _buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderTrabajando,WalkieTaskColors.white,3,task),
                  _buttonSliderAction('LISTO',Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.04,),colorSliderListo,WalkieTaskColors.white,4,task),
                ],
              ),
            ),
          ),
      );
      data.add(Divider());
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
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          child: Icon(Icons.arrow_back_ios, size: alto * 0.035, color: WalkieTaskColors.primary,),
        ),
      ),
      bottom: _indicatorProgress(),
    );
  }

  String getDayDiff(String deadLine){
    String daysLeft = '';
    if(deadLine.isNotEmpty){
      daysLeft = 'Ahora';
      DateTime dateCreate = DateTime.parse(deadLine);
      Duration difDays = dateCreate.difference(DateTime.now());
      if(difDays.inMinutes > 0){
        if(difDays.inMinutes < 60){
          daysLeft = '${difDays.inMinutes} min';
        }else{
          if(difDays.inHours < 24){
            daysLeft = '${difDays.inHours} horas';
          }else{
            double days = difDays.inHours / 24;
            daysLeft = '${days.toStringAsFixed(0)} días';
          }
        }
      }else{
        if((difDays.inMinutes * -1) < 60){
          daysLeft = '-${difDays.inMinutes} min';
        }else{
          if((difDays.inHours * -1) < 24){
            daysLeft = '-${difDays.inHours} horas';
          }else{
            double days = (difDays.inHours * -1) / 24;
            daysLeft = '-${days.toStringAsFixed(0)} días';
          }
        }
      }
    }
    return daysLeft;
  }

  void clickTarea(Tarea tarea) async {

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
          if(tarea.is_priority == 0){tarea.is_priority = 1;}else{tarea.is_priority = 0;}
          //GUARDAR LOCALMENTE
          if(await DatabaseProvider.db.updateTask(tarea) == 1){
            //AVISAR A PATRONBLOC DE TAREAS ENVIADAS PARA QUE SE ACTUALICE
            widget.blocTaskReceived.inList.add(true);
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
                widget.blocTaskReceived.inList.add(true);
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
                widget.blocTaskReceived.inList.add(true);
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
