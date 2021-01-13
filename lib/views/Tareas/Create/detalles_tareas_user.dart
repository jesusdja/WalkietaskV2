import 'dart:async';

import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/task_sound.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';

class DetailsTasksForUser extends StatefulWidget {

  final bool isPersonal;
  final Usuario user;
  final Map<int,List> mapDataUserHome;
  final List<Caso> listaCasos;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;

  DetailsTasksForUser({
    @required this.user,
    @required this.isPersonal,
    @required this.mapDataUserHome,
    @required this.listaCasos,
    @required this.blocTaskReceived,
    @required this.blocTaskSend,
  });

  @override
  _DetailsTasksForUserState createState() => _DetailsTasksForUserState();
}

class _DetailsTasksForUserState extends State<DetailsTasksForUser> {

  double alto = 0;
  double ancho = 0;

  TextStyle textStylePrimary;
  TextStyle textStyleBlue;
  TextStyle textStyleBlueLitle;
  TextStyle textStylePrimaryBold;
  TextStyle textStylePrimaryLitle;
  TextStyle textStylePrimaryLitleRed;

  bool isPersonal = false;
  Usuario user;
  Map<int,List> mapDataUserHome;

  List<Tarea> listRecived = [];
  List<Tarea> listSend = [];

  Map<int,Caso> mapCasos = {};

  StreamSubscription streamSubscriptionTaskSend;
  StreamSubscription streamSubscriptionTaskRecived;

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
  }

  @override
  void dispose() {
    super.dispose();
    try{
      streamSubscriptionTaskSend?.cancel();
      streamSubscriptionTaskRecived?.cancel();
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
        bottomNavigationBar: _bottomNavigationBar(),
        body: _body(),
      ),
    );
  }

  Widget _body(){

    double h = alto < 600 ? alto * 0.32 : alto * 0.34;

    return Container(
      width: ancho,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: ancho,
            height: alto * 0.06,
            //color: Colors.orange,
            child: Container(
              margin: EdgeInsets.only(top: alto * 0.02, left: ancho * 0.03),
              child: Text('Tareas recibidas', style: textStylePrimaryBold,),
            ),
          ),
          Container(
            width: ancho,
            height: h,
            //color: Colors.red,
            child: _listTaskRecived(h),
          ),
          Container(
            width: ancho,
            height: alto * 0.06,
            //color: Colors.blue,
            child: Container(
              margin: EdgeInsets.only(top: alto * 0.02, left: ancho * 0.03),
              child: Text('Tareas enviadas', style: textStylePrimaryBold,),
            ),
          ),
          Container(
            width: ancho,
            height: h,
            //color: Colors.grey,
            child: _listTaskSend(h),
          ),
        ],
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
              padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
              width: ancho,
              child: Row(
                children: [
                  Container(
                    width: ancho * 0.06,
                    child: daysLeft.contains('-') ? Container(
                      padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                      height: alto * 0.02,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ) : Container(),
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
              padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01),
              width: ancho,
              child: Row(
                children: [
                  Container(
                    width: ancho * 0.06,
                    child: daysLeft.contains('-') ? Container(
                      padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                      height: alto * 0.02,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ) : Container(),
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
            Text(isPersonal ? 'Recordatorio Personal' : user.name, style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.025, color: WalkieTaskColors.black, spacing: 0.5, ),)
          ],
        ),
      ),
      leading: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          child: Icon(Icons.arrow_back_ios, size: alto * 0.035, color: WalkieTaskColors.primary,),
        ),
      ),
    );
  }

  Widget _bottomNavigationBar(){
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01, left: ancho * 0.02, right: ancho * 0.04),
      width: ancho,
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Text('Nueva tarea para ${user.name}:', style: textStyleBlue,maxLines: 2,),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: alto * 0.03,
                  width: alto * 0.025,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ViewImage().assetsImage("assets/image/Icon_text.png", color: WalkieTaskColors.primary).image,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Text('Texto', style: textStyleBlueLitle,)
              ],
            ),
          ),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: alto * 0.03,
                  width: alto * 0.025,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ViewImage().assetsImage("assets/image/Icon_microphone_blue.png", color: WalkieTaskColors.primary).image,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Text('Audio', style: textStyleBlueLitle,)
              ],
            ),
          ),
        ],
      ),
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
        // if(result){
        //   blocTaskReceived.inList.add(true);
        // }
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
          _UpdateTask();
        }
      });
    } catch (e) {}
  }
  _inicializarPatronBlocTaskRecived(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionTaskRecived = widget.blocTaskReceived.outList.listen((newVal) {
        if(newVal){
          _UpdateTask();
        }
      });
    } catch (e) {}
  }

  _UpdateTask() async {
    listSend = await TaskDatabaseProvider.db.getAllSend();
    listRecived = await TaskDatabaseProvider.db.getAllRecevid();
    setState(() {});
  }
}
