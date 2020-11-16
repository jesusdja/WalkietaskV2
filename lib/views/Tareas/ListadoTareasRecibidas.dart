import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/switch_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

import '../Chat/ChatForTarea.dart';

class ListadoTareasRecibidas extends StatefulWidget {

  ListadoTareasRecibidas({this.mapIdUserRes,this.listRecibidos,this.blocTaskReceivedRes,this.listaCasosRes});
  final Map<int,Usuario> mapIdUserRes;
  final List<Tarea> listRecibidos;
  final BlocTask blocTaskReceivedRes;
  final List<Caso> listaCasosRes;

  @override
  _ListadoTareasState createState() => _ListadoTareasState();
}

class _ListadoTareasState extends State<ListadoTareasRecibidas> {

  List<Tarea> listaTareas = new List<Tarea>();
  double alto = 0;
  double ancho = 0;
  List<Tarea> listRecibidos;

  Map<int,Usuario> mapIdUser;
  BlocTask blocTaskReceived;

  bool valueSwitch = true;
  Map<int,bool> mapAppBar = {0:true,1:false,2:false};
  UpdateData updateData = new UpdateData();
  conexionHttp conexionHispanos = new conexionHttp();

  Map<int,bool> openForUserTask = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blocTaskReceived = widget.blocTaskReceivedRes;
    _inicializar();
    _inicializar2();
  }

  _inicializar(){
    mapIdUser = widget.mapIdUserRes;
    listRecibidos = widget.listRecibidos;
    setState(() {});
  }

  _inicializar2(){
    if(widget.mapIdUserRes != null){
      mapIdUser.forEach((key, value) {
        openForUserTask[key] = false;
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;
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
              onChanged: (bool val){
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
    return Container(
        height: alto * 0.7,
        child: ReorderableListView(
          children: List.generate(listRecibidos.length, (index) {
            Tarea tarea = listRecibidos[index];
            return Container(
              height: alto * 0.1,
              key: ValueKey("value$index"),
              padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: _tareas(tarea, tarea.is_priority != 0),
                actions: <Widget>[
                  _ButtonSliderAction(tarea.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: Colors.white,size: 30,),Colors.yellow[600],Colors.white,1,tarea),
                  _ButtonSliderAction('COMENTAR',Icon(Icons.message,color: Colors.white,size: 30,),Colors.deepPurple[200],Colors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  _ButtonSliderAction('TRABAJANDO',Icon(Icons.build,color: Colors.white,size: 30,),colorSliderTrabajando,Colors.white,3,tarea),
                  _ButtonSliderAction('LISTO',Icon(Icons.check,color: Colors.white,size: 30,),colorSliderListo,Colors.white,4,tarea),
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

  Widget _tareas(Tarea tarea, bool favorite,){
    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(mapIdUser[tarea.user_id] != null && mapIdUser[tarea.user_id].avatar != ''){
        avatarUser = Image.network('$directorioImage${mapIdUser[tarea.user_id].avatar}');
      }
    }

    String daysLeft = 'Ahora';
    DateTime dateCreate = DateTime.parse(tarea.created_at);
    Duration difDays = DateTime.now().difference(dateCreate);
    if(difDays.inMinutes > 5){
      if(difDays.inMinutes < 60){
        daysLeft = 'Hace ${difDays.inMinutes} min';
      }else{
        if(difDays.inHours < 24){
          daysLeft = 'Hace ${difDays.inHours} horas';
        }else{
          double days = difDays.inHours / 24;
          daysLeft = 'Hace ${days.toStringAsFixed(0)} días';
        }
      }
    }

    return InkWell(
      onTap: () =>clickTarea(tarea),
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              width: ancho * 0.2,
              child: Stack(
                children: <Widget>[
                  Center(
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
                  favorite ? Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(right: ancho * 0.02),
                      child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                    ),
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
                    Flexible(
                      flex: 1,
                      child: Text(mapIdUser[tarea.user_id] == null ? '' : mapIdUser[tarea.user_id].name,
                          maxLines: 1,
                          style: favorite ?
                          WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black) :
                          WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02, color: Colors.grey[600])), //estiloLetras(alto * 0.02,Colors.grey[600]),),
                    ),
                    Flexible(
                        flex: 1,
                        child: Text(tarea.name.isNotEmpty ? tarea.name : 'Tarea sin título. Tap para nombrarla',
                          maxLines: 1,
                      style: tarea.name.isNotEmpty ? favorite ?
                          WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black) :
                          WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02, color: WalkieTaskColors.black) :
                        WalkieTaskStyles().styleNunitoRegular(size: alto * 0.018, color: WalkieTaskColors.primary),)
                    ),
                    Text('(Sin proyecto asignado)',style: estiloLetras(alto * 0.017,Colors.grey[600]),maxLines: 1,),
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
                  Text(daysLeft,style: estiloLetras(alto * 0.018,Colors.grey[600]),),
                  SizedBox(height: alto * 0.006,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      //Icon(Icons.message,color: Colors.grey[600],size: alto * 0.03),
                      favorite ? CircleAvatar(
                        backgroundColor: WalkieTaskColors.primary,
                        radius: alto * 0.012,
                        child: Text('2',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                      ) : Container(),
                      favorite ? SizedBox(width: ancho * 0.01,) : Container(),
                      tarea.url_audio != '' ? Icon(Icons.volume_up,color:  Colors.grey[600],size: alto * 0.03,) : Container()
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
    listRecibidos.forEach((element) {
      if(mapTask[element.user_id] == null){ mapTask[element.user_id] = [];}
      mapTask[element.user_id].add(element);
    });

    return Container(
      width: ancho,
      height: alto * 0.7,
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

    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(user != null && user.avatar != ''){
        avatarUser = Image.network('$directorioImage${user.avatar}');
      }
    }

    List<Widget> listTaskWidget = listTaskGet(user, listTask);

    return Container(
      width: ancho,
      child: Column(
        children: <Widget>[
          Container(
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
                    //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: ancho * 0.03,right: ancho * 0.03,),
                    // child: Text('${user.name}',
                    //     style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_76ADE3)),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: '${user.name}',
                        style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_76ADE3),
                        children: [
                          TextSpan(
                            text: '   (${listTask.length} ${listTask.length < 1 ? 'tarea' : 'Tareas'})',
                            style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Container(
                //   child: Text('(${listTask.length} ${listTask.length < 1 ? 'tarea' : 'Tareas'})',
                //       style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 1)),
                // ),
                InkWell(
                  child: Container(
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
                  onTap: (){
                    openForUserTask[user.id] = !openForUserTask[user.id];
                    setState(() {});
                  },
                ),
              ],
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
    bool smsRecived = true;
    listTask.forEach((task) {

      String daysLeft = 'Ahora';
      DateTime dateCreate = DateTime.parse(task.created_at);
      Duration difDays = DateTime.now().difference(dateCreate);
      if(difDays.inMinutes > 5){
        if(difDays.inMinutes < 60){
          daysLeft = 'Hace ${difDays.inMinutes} min';
        }else{
          if(difDays.inHours < 24){
            daysLeft = 'Hace ${difDays.inHours} horas';
          }else{
            double days = difDays.inHours / 24;
            daysLeft = 'Hace ${days.toStringAsFixed(0)} días';
          }
        }
      }

      smsRecived = !smsRecived;

      listTaskRes.add(
          InkWell(
            onTap: () =>clickTarea(task),
            child: Container(
                width: ancho,
                padding: EdgeInsets.only(left: ancho * 0.04, right: ancho * 0.04,top: alto * 0.005),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(task.name.isEmpty ? 'Nombre no asignado' : task.name,
                                style: smsRecived ?
                                WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black) :
                                WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02, color: Colors.grey[600])),
                            Text(task.name,
                              style: smsRecived ?
                              WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black) :
                              WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02, color: WalkieTaskColors.primary),),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: ancho * 0.3,
                      margin: EdgeInsets.only(right: ancho * 0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(daysLeft,style: estiloLetras(alto * 0.018,Colors.grey[600]),),
                          SizedBox(height: alto * 0.006,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              //Icon(Icons.message,color: Colors.grey[600],size: alto * 0.03),
                              smsRecived ? CircleAvatar(
                                backgroundColor: WalkieTaskColors.primary,
                                radius: alto * 0.012,
                                child: Text('2',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                              ) : Container(),
                              smsRecived ? SizedBox(width: ancho * 0.01,) : Container(),
                              task.url_audio != '' ? Icon(Icons.volume_up,color:  Colors.grey[600],size: alto * 0.03,) : Container()
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          )
      );

    });
    return listTaskRes;
  }

  Widget _listadoProyect(){
    return Container(
        height: alto * 0.7,
        child: ReorderableListView(
          children: List.generate(listRecibidos.length, (index) {
            Tarea tarea = listRecibidos[index];
            return Container(
              height: alto * 0.1,
              key: ValueKey("value$index"),
              padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child:  _tareasProyect(tarea, tarea.is_priority != 0),
                actions: <Widget>[
                  _ButtonSliderAction(tarea.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: Colors.white,size: 30,),Colors.yellow[600],Colors.white,1,tarea),
                  _ButtonSliderAction('COMENTAR',Icon(Icons.message,color: Colors.white,size: 30,),Colors.deepPurple[200],Colors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  _ButtonSliderAction('TRABAJANDO',Icon(Icons.build,color: Colors.white,size: 30,),colorSliderTrabajando,Colors.white,3,tarea),
                  _ButtonSliderAction('LISTO',Icon(Icons.check,color: Colors.white,size: 30,),colorSliderListo,Colors.white,4,tarea),
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

  Widget _tareasProyect(Tarea tarea, bool favorite,){

    return Container();
    /*
    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(mapIdUser[tarea.user_id] != null && mapIdUser[tarea.user_id].avatar != ''){
        avatarUser = Image.network('$directorioImage${mapIdUser[tarea.user_id].avatar}');
      }
    }

    String daysLeft = 'Ahora';
    DateTime dateCreate = DateTime.parse(tarea.created_at);
    Duration difDays = DateTime.now().difference(dateCreate);
    if(difDays.inMinutes > 5){
      if(difDays.inMinutes < 60){
        daysLeft = 'Hace ${difDays.inMinutes} min';
      }else{
        if(difDays.inHours < 24){
          daysLeft = 'Hace ${difDays.inHours} horas';
        }else{
          double days = difDays.inHours / 24;
          daysLeft = 'Hace ${days.toStringAsFixed(0)} días';
        }
      }
    }
    return InkWell(
      onTap: () =>clickTarea(tarea),
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              width: ancho * 0.2,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(3.0), // borde width
                      decoration: new BoxDecoration(
                        color: bordeCirculeAvatar, // border color
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: alto * 0.035,
                        backgroundImage: avatarUser.image,
                        //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                      ),
                    ),
                  ),
                  favorite ? Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(right: ancho * 0.02),
                      child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.032,),
                    ),
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
                    Flexible(
                      flex: 1,
                      child: Text(mapIdUser[tarea.user_id] == null ? '' : mapIdUser[tarea.user_id].name,
                          style: favorite ?
                          WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black) :
                          WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02, color: Colors.grey[600])), //estiloLetras(alto * 0.02,Colors.grey[600]),),
                    ),
                    Flexible(
                        flex: 1,
                        child: Text(tarea.name,
                          style: favorite ?
                          WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black) :
                          WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02, color: WalkieTaskColors.primary),)
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: ancho * 0.3,
              margin: EdgeInsets.only(right: ancho * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(daysLeft,style: estiloLetras(alto * 0.018,Colors.grey[600]),),
                  SizedBox(height: alto * 0.006,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      //Icon(Icons.message,color: Colors.grey[600],size: alto * 0.03),
                      favorite ? CircleAvatar(
                        backgroundColor: WalkieTaskColors.primary,
                        radius: alto * 0.012,
                        child: Text('2',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                      ) : Container(),
                      favorite ? SizedBox(width: ancho * 0.01,) : Container(),
                      tarea.url_audio != '' ? Icon(Icons.volume_up,color:  Colors.grey[600],size: alto * 0.03,) : Container()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    */
  }

  Widget clickTarea(Tarea tarea){
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new ChatForTarea(tareaRes: tarea,listaCasosRes: widget.listaCasosRes,)));
  }

  Widget _ButtonSliderAction(String titulo,Icon icono,Color color,Color colorText,int accion,Tarea tarea){
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
          if(await TaskDatabaseProvider.db.updateTask(tarea) == 1){
            //AVISAR A PATRONBLOC DE TAREAS ENVIADAS PARA QUE SE ACTUALICE
            blocTaskReceived.inList.add(true);
            //ENVIAR A API
            try{
              var result = await conexionHispanos.httpModificarTarea(tarea);
            }catch(e){
            //SI NO HAY CONEXION GUARDAR EN TABLA LOCAL

            }
          }
        }
      },
    );
  }

  void _updateMyItems(int oldIndex, int newIndex) {

    List<Tarea> AuxList = new List<Tarea>();
    List<Tarea> listRecibidosRecorrer = listRecibidos;
    Tarea tareaOrder = listRecibidosRecorrer[oldIndex];
    listRecibidosRecorrer.removeAt(oldIndex);
    int y = 0;
    if(newIndex == 0){
      tareaOrder.order = 0;
      AuxList.add(tareaOrder);
      y++;
    }

    bool entrar = false;
    if(listRecibidosRecorrer.length == newIndex){
      entrar = true;
    }

    for(int x = 0; x < listRecibidosRecorrer.length; x++){
      if(x == newIndex && newIndex != 0){
        tareaOrder.order = y;
        AuxList.add(tareaOrder);
        y++;
      }
      if((x+1) == newIndex && entrar){
        tareaOrder.order = y;
        AuxList.add(tareaOrder);
        y++;
      }
      listRecibidosRecorrer[x].order = y;
      AuxList.add(listRecibidosRecorrer[x]);
      y++;
    }
    if(newIndex > listRecibidosRecorrer.length){
      tareaOrder.order = y;
      AuxList.add(tareaOrder);
    }
    listRecibidos.clear();
    for(int x = 0; x < AuxList.length; x++){
      listRecibidos.add(AuxList[x]);
    }
    setState(() {});
    updateData.organizarTareas(AuxList,blocTaskReceived);
  }
}