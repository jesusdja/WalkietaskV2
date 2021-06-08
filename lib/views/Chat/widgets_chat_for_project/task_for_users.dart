import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
import 'package:walkietaskv2/utils/walkietask_style.dart';

class TaskForUsers extends StatefulWidget {

  TaskForUsers({@required this.project, @required this.widgetHome, @required this.mapIdUser});
  final Caso project;
  final Map<String,dynamic> widgetHome;
  final Map<int,Usuario> mapIdUser;

  @override
  _TaskForUsersState createState() => _TaskForUsersState();
}

class _TaskForUsersState extends State<TaskForUsers> {

  double alto = 0;
  double ancho = 0;
  String idMyUser = '0';
  Caso project;
  bool allOrMe = true;
  Map<String,dynamic> widgetHome = {};
  List<Tarea> listTask = [];
  bool loadData = true;
  Map<int,Usuario> mapIdUser = {};

  @override
  void initState() {
    super.initState();
    project = widget.project;
    widgetHome = widget.widgetHome;
    mapIdUser = widget.mapIdUser;
    initialUser();
  }

  initialUser() async {
    idMyUser = await SharedPrefe().getValue('unityIdMyUser');

    List<Tarea> listA = [];
    List<Tarea> listB = [];

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
    loadData = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: ancho,
            padding: EdgeInsets.symmetric(vertical: alto * 0.01),
            color: Colors.grey[100],
            child: _appBArMenu(),
          ),
          Flexible(
            child: loadData ?
            Container(
              width: ancho,
              height: alto * 0.8,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ) :
            listTask.isEmpty ?
            Container(
              width: ancho,
              height: alto * 0.8,
              child: Center(
                child: Text(translate(context: context, text: 'noReceivedTasks'), style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D,spacing: 0.5),),
              ),
            ) :
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //allOrMe ? _listado() : Container(),
                  !allOrMe ? Container() : Container(),
                  // mapAppBar[2] ? _listadoProyect() : Container(),
                ],
              ),
            ),
          )
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
        ],
      ),
    );
  }

  Widget _appBArMenuText(String text, int index){
    bool viewLine = false;
    if((index == 0 && allOrMe) || (index == 1 && !allOrMe)){
      viewLine = true;
    }

    return InkWell(
      onTap: (){
        allOrMe = index == 0;
        setState(() {});
      },
      child: Column(
        children: <Widget>[
          Text(text, style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.018, color: WalkieTaskColors.primary),),
          viewLine ? Container(
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

  // Widget _listado(){
  //   double h = alto > 600 ? alto * 0.8 : alto * 0.7;
  //
  //   return Container(
  //       height: h,
  //       child: ReorderableListView(
  //         children: List.generate(listTask.length, (index) {
  //           Tarea tarea = listTask[index];
  //
  //           if(tarea.finalized == 1){
  //             return Container(
  //               key: ValueKey("value$index"),
  //             );
  //           }
  //
  //           return Container(
  //             key: ValueKey("value$index"),
  //             padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
  //             color: Colors.white,
  //             child: Slidable(
  //               actionPane: SlidableDrawerActionPane(),
  //               actionExtentRatio: 0.25,
  //               child: _tareas(tarea),
  //               actions: <Widget>[
  //                 _buttonSliderAction(tarea.is_priority_responsability == 0 ? translate(context: context,text: 'highlight') : translate(context: context, text: 'forget'),Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),WalkieTaskColors.yellow,WalkieTaskColors.white,1,tarea),
  //                 //_buttonSliderAction('COMENTAR',Icon(Icons.message,color: WalkieTaskColors.white,size: 30,),Colors.deepPurple[200],WalkieTaskColors.white,2,tarea),
  //               ],
  //               secondaryActions: <Widget>[
  //                 _buttonSliderAction(translate(context: context, text: 'working'),Icon(Icons.build,color: WalkieTaskColors.white,size: alto * 0.045,),colorSliderTrabajando,WalkieTaskColors.white,3,tarea),
  //                 _buttonSliderAction(translate(context: context, text: 'ready'),Icon(Icons.check,color: WalkieTaskColors.white,size: alto * 0.045,),colorSliderListo,WalkieTaskColors.white,4,tarea),
  //               ],
  //             ),
  //           );
  //         }),
  //         onReorder: (int oldIndex, int newIndex) {
  //           //_updateMyItems(oldIndex, newIndex);
  //         },
  //       )
  //   );
  // }
  //
  // Widget _tareas(Tarea tarea, ){
  //
  //   bool favorite = tarea.is_priority_responsability == 1;
  //
  //   bool isNew = false;
  //   listViewTaskNew.forEach((element) {
  //     if(element == tarea.id.toString()){
  //       isNew = true;
  //     }
  //   });
  //
  //   bool working = tarea.working == 1;
  //
  //
  //   String daysLeft = getDayDiff(tarea.deadline);
  //
  //   String proyectName = project.name ?? translate( context: context, text: 'noAssignedProject');
  //
  //   String nameUser = '';
  //   if(mapIdUser[tarea.user_id] != null){
  //     nameUser = '${mapIdUser[tarea.user_id].name} ${mapIdUser[tarea.user_id].surname}';
  //     if(widget.myUserRes != null && widget.myUserRes.id != null && widget.myUserRes.id == mapIdUser[tarea.user_id].id){
  //       nameUser = translate(context: context, text: 'remindersPersonal');
  //     }
  //   }
  //
  //   Widget avatarUser = avatarWidget(alto: alto,text: nameUser.isEmpty ? '' : nameUser.substring(0,1).toUpperCase());
  //   if(mapIdUser != null){
  //     if(mapIdUser[tarea.user_id] != null && mapIdUser[tarea.user_id].avatar_100 != ''){
  //       avatarUser = avatarWidgetImage(alto: alto,pathImage: mapIdUser[tarea.user_id].avatar_100);
  //     }
  //   }
  //
  //   int chatCont = 0;
  //   listCheckChat.forEach((element) {
  //     if(tarea.id.toString() == element){
  //       chatCont++;
  //     }
  //   });
  //   double radiusChat = 0.012;
  //   if(chatCont >= 10 && chatCont < 100){radiusChat = 0.014; }
  //   if(chatCont > 100){radiusChat = 0.018; }
  //
  //   bool activity = chatCont != 0;
  //   if(!activity) { activity = isNew;}
  //
  //   return InkWell(
  //     onTap: () =>clickTarea(tarea),
  //     child: Container(
  //       child: IntrinsicHeight(
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             working ? Container(
  //               width: ancho * 0.015,
  //               color: WalkieTaskColors.color_89BD7D,
  //             ) : Container(width: ancho * 0.015,),
  //             Container(
  //               width: ancho * 0.18,
  //               child: Stack(
  //                 children: <Widget>[
  //                   Container(
  //                     padding: EdgeInsets.only(left: ancho * 0.015),
  //                     child: Container(
  //                       padding: const EdgeInsets.all(3.0), // borde width
  //                       decoration: new BoxDecoration(
  //                         color: bordeCirculeAvatar, // border color
  //                         shape: BoxShape.circle,
  //                       ),
  //                       child: avatarUser,
  //                     ),
  //                   ),
  //                   favorite ? Container(
  //                     margin: EdgeInsets.only(left: ancho * 0.1, top: alto * 0.04),
  //                     child: Icon(Icons.star,color: WalkieTaskColors.yellow, size: alto * 0.03,),
  //                   ) : Container(),
  //                 ],
  //               ),
  //             ),
  //             Expanded(
  //               child: Container(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: <Widget>[
  //                     Text('$nameUser', style: activity ? textStylePrimaryBold : textStylePrimary),
  //                     Text(tarea.name.isNotEmpty ? tarea.name : translate(context: context, text: 'untitledTask'),
  //                       style: tarea.name.isNotEmpty ? (activity ? textStylePrimaryBold : textStylePrimary) : textStyleNotTitle,),
  //                     Text(proyectName,style: textStyleProject,),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SoundTask(
  //               alto: alto * 0.03,
  //               colorStop: WalkieTaskColors.color_E07676,
  //               path: tarea.url_audio,
  //               idTask: tarea.id,
  //               blocAudioChangePage: widget.blocAudioChangePage,
  //               page: bottonSelect.opcion2,
  //               chatCont: chatCont != 0 ? Container(
  //                 margin: EdgeInsets.only(right: ancho * 0.002),
  //                 child: CircleAvatar(
  //                   backgroundColor: WalkieTaskColors.primary,
  //                   // 100 alto * 0.018, / 10 alto * 0.014, / 1 alto * 0.012,
  //                   radius: alto * radiusChat,
  //                   child: Text('$chatCont',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
  //                 ),
  //               ) : Container(),
  //               textDate: Text(daysLeft.replaceAll('-', ''),style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: daysLeft.contains('-') ? WalkieTaskColors.color_E07676 : Colors.grey[600]),),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buttonSliderAction(String titulo,Icon icono,Color color,Color colorText,int accion,Tarea tarea){
  //   return IconSlideAction(
  //     color: color,
  //     iconWidget: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         icono,
  //         Text('$titulo',style: estiloLetras(alto * 0.013, Colors.white,fontFamily: 'helveticaneue2'),),
  //       ],
  //     ),
  //     onTap: () async {
  //       if(accion == 1){
  //         if(tarea.is_priority_responsability == 0){tarea.is_priority_responsability = 1;}else{tarea.is_priority_responsability = 0;}
  //         tarea.updated_at = DateTime.now().toString();
  //         int result = await DatabaseProvider.db.updateTask(tarea);
  //         if(result == 1){
  //           blocTaskReceived.inList.add(true);
  //           try{
  //             await conexionHttp().httpSendFavorite(tarea,tarea.is_priority_responsability);
  //           }catch(e){
  //             print(e.toString());
  //           }
  //           blocTaskReceived.inList.add(true);
  //         }
  //       }
  //       if(accion == 3){
  //         try{
  //           if(tarea.working == 0){
  //             showAlert(translate(context: context, text: 'TaskStarted'),WalkieTaskColors.color_89BD7D);
  //             tarea.working = 1;
  //             tarea.updated_at = DateTime.now().toString();
  //             if(await DatabaseProvider.db.updateTask(tarea) == 1){
  //               blocTaskReceived.inList.add(true);
  //               await conexionHttp().httpTaskInit(tarea.id);
  //               UpdateData().actualizarListaRecibidos(blocTaskReceived, null);
  //             }
  //           }else{
  //             showAlert(translate(context: context, text: 'TaskAlreadyStarted'),WalkieTaskColors.color_89BD7D);
  //           }
  //         }catch(e){
  //           print(e.toString());
  //         }
  //         blocTaskReceived.inList.add(true);
  //       }
  //       if(accion == 4){
  //         if(tarea.working == 1 || tarea.working == 0){
  //           showAlert(translate(context: context, text: 'TaskFinished'),WalkieTaskColors.color_89BD7D);
  //           try{
  //             tarea.finalized = 1;
  //             tarea.updated_at = DateTime.now().toString();
  //             if(await DatabaseProvider.db.updateTask(tarea) == 1){
  //               blocTaskReceived.inList.add(true);
  //               await conexionHttp().httpTaskFinalized(tarea.id);
  //               UpdateData().actualizarListaRecibidos(blocTaskReceived, null);
  //             }
  //           }catch(e){
  //             print(e.toString());
  //           }
  //           blocTaskReceived.inList.add(true);
  //         }else{
  //           showAlert('La tarea debe estar iniciada para finalizarla.',WalkieTaskColors.color_E07676);
  //         }
  //       }
  //     },
  //   );
  // }
}
