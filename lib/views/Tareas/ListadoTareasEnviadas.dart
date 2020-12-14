import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/switch_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';

class ListadoTareasEnviadas extends StatefulWidget {

  ListadoTareasEnviadas({this.listEnviadosRes,this.mapIdUserRes,this.blocTaskSendRes,this.listaCasosRes, this.myUserRes});
  final List<Tarea> listEnviadosRes;
  final Map<int,Usuario> mapIdUserRes;
  final BlocTask blocTaskSendRes;
  final List<Caso> listaCasosRes;
  final Usuario myUserRes;

  @override
  _ListadoTareasState createState() => _ListadoTareasState();
}

class _ListadoTareasState extends State<ListadoTareasEnviadas> {

  Map<int,bool> mapAppBar = {0:true,1:false,2:false};
  bool valueSwitch = false;

  List<Tarea> listEnviados;
  Map<int,Usuario> mapIdUser;
  Map<int,Caso> mapCasos = {};
  Map<int,bool> openForUserTask = {};
  Map<int,bool> openForProyectTask = {0 : false};

  double alto = 0;
  double ancho = 0;

  BlocTask blocTaskSend;

  conexionHttp conexionHispanos = new conexionHttp();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blocTaskSend = widget.blocTaskSendRes;
    widget.listaCasosRes.forEach((element) { mapCasos[element.id] = element;});
    _inicializar();
    _inicializar2();
    _inicializar3();
  }

  void _inicializar(){
    mapIdUser = widget.mapIdUserRes;
    if(valueSwitch){
      orderListTaskDeadLine();
    }else{
      listEnviados = widget.listEnviadosRes;
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

  void _inicializar3(){
    if(widget.listaCasosRes.isNotEmpty){
      mapCasos.forEach((key, value) {
        openForProyectTask[key] = false;
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

  Widget _listado(){
    return Container(
        height: alto * 0.7,
        child: ReorderableListView(
          children: List.generate(listEnviados.length, (index) {
            Tarea tarea = listEnviados[index];
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
                  _buttonSliderAction(tarea.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: Colors.white,size: 30,),Colors.yellow[600],Colors.white,1,tarea),
                  _buttonSliderAction('COMENTAR',Icon(Icons.message,color: Colors.white,size: 30,),Colors.deepPurple[200],Colors.white,2,tarea),
                ],
                secondaryActions: <Widget>[
                  _buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: Colors.white,size: 30,),colorSliderTrabajando,Colors.white,3,tarea),
                  _buttonSliderAction('LISTO',Icon(Icons.check,color: Colors.white,size: 30,),colorSliderListo,Colors.white,4,tarea),
                ],
              ),
            );
          }),
          onReorder: (int oldIndex, int newIndex) {
            //_updateMyItems(oldIndex, newIndex);
          },
        )
    );
  }

  Widget _tareas(Tarea tarea, bool favorite,){
    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(mapIdUser[tarea.user_responsability_id] != null && mapIdUser[tarea.user_responsability_id].avatar != ''){
        avatarUser = Image.network('$directorioImage${mapIdUser[tarea.user_responsability_id].avatar}');
      }
    }

    String daysLeft = getDayDiff(tarea.deadline);

    String proyectName = '(Sin proyecto asignado)';
    if(tarea.project_id != null && tarea.project_id != 0 && mapCasos[tarea.project_id] != null){
      proyectName = mapCasos[tarea.project_id].name;
    }

    String nameUser = '';
    if(mapIdUser[tarea.user_responsability_id] != null){
      nameUser = mapIdUser[tarea.user_responsability_id].name;
      if(widget.myUserRes.id == mapIdUser[tarea.user_responsability_id].id){
        nameUser = 'Recordatorio personal';
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
                      child: Text(nameUser,
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
                    Text(proyectName,style: estiloLetras(alto * 0.017,Colors.grey[600]),maxLines: 1,),
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
/*
  _listado2(){
    return Container(
      height: alto * 0.74,
      child: ListView.builder(
        itemCount: listEnviados.length,
        itemBuilder: (context,index){
          int keyMap = listEnviados.keys.elementAt(index);

          Image avatarUser = Image.network(avatarImage);
          if(mapIdUser != null){
            if(mapIdUser[keyMap] != null && mapIdUser[keyMap].avatar != ''){
              avatarUser = Image.network('$directorioImage${mapIdUser[keyMap].avatar}');
            }
          }

          return Container(
            child: Column(
              children: <Widget>[
                keyMap == 0 ? Container() : Container(
                  padding: EdgeInsets.only(top: alto * 0.02,bottom: alto * 0.02),
                  margin: EdgeInsets.only(bottom: alto * 0.004),
                  color: colorTareasEnviadas,
                  child: InkWell(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: ancho * 0.3,
                          padding: EdgeInsets.only(right: ancho * 0.06,left: ancho * 0.06),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[500],
                            radius: ancho * 0.08,
                            backgroundImage: avatarUser.image,
                          ),
                        ),
                        Container(
                          width: ancho * 0.5,
                          child: Center(
                            child: Container(
                              width: ancho * 0.5,
                              child: Text(mapIdUser[keyMap] == null ? '' : mapIdUser[keyMap].name,
                                style: estiloLetras(alto * 0.028,Colors.white),),
                            ),
                          ),
                        ),
                        Container(
                          width: ancho * 0.2,
                          child: Center(
                            child: Icon(abrirMenu[keyMap] ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_left,size: alto * 0.04,color: Colors.white,),
                          ),
                        )
                      ],
                    ),
                    onTap: (){
                      setState(() {
                        abrirMenu[keyMap] = !abrirMenu[keyMap];
                      });
                    },
                  ),
                ),
                (abrirMenu[keyMap] || keyMap == 0) ? _tareasPorUser(listEnviados[keyMap]) : Container(),
              ],
            ),
          );
        },
      )
    );
  }
*/

  Widget _listadoUser(){
    Map<int,List<Tarea>> mapTask = {};
    listEnviados.forEach((element) {
      if(mapTask[element.user_responsability_id] == null){ mapTask[element.user_responsability_id] = [];}
      mapTask[element.user_responsability_id].add(element);
    });

    return Container(
      width: ancho,
      height: alto * 0.7,
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
        avatarUser = Image.network('$directorioImage${user.avatar}');
      }
    }

    List<Widget> listTaskWidget = listTaskGet(user, listTask);

    String nameUser = user.name;
    if(widget.myUserRes.id == user.id){
      nameUser = 'Recordatorio personal';
    }

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
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: ancho * 0.03,right: ancho * 0.03,),
                    child: Text(nameUser,
                        style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_76ADE3)),
                  ),
                ),
                Container(
                  child: Text('(${listTask.length} ${listTask.length < 1 ? 'tarea' : 'Tareas'})',
                      style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 1)),
                ),
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
    listTask.forEach((task) {


      String proyectName = '(Sin proyecto asignado)';
      if(task.project_id != null && task.project_id != 0 && mapCasos[task.project_id] != null){
        proyectName = mapCasos[task.project_id].name;
      }

      String daysLeft = getDayDiff(task.deadline);

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
                              maxLines: 1,
                              style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022, color: Colors.grey[600])),
                          Text(proyectName,
                            maxLines: 1,
                            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.018, color: WalkieTaskColors.color_969696),),
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
                            // smsRecived ? CircleAvatar(
                            //   backgroundColor: WalkieTaskColors.primary,
                            //   radius: alto * 0.012,
                            //   child: Text('2',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),),
                            // ) : Container(),
                            // smsRecived ? SizedBox(width: ancho * 0.01,) : Container(),
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
    Map<int,List<Tarea>> mapTask = {};
    listEnviados.forEach((element) {
      int idProyect = element.project_id ?? 0;
      if(mapTask[idProyect] == null){ mapTask[idProyect] = [];}
      mapTask[idProyect].add(element);
    });
    return Container(
      width: ancho,
      height: alto * 0.7,
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

    return Container(
      width: ancho,
      child: Column(
        children: <Widget>[
          Container(
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
                  child: Text('(${listTask.length} ${listTask.length < 1 ? 'tarea' : 'Tareas'})',
                      style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 1)),
                ),
                InkWell(
                  child: Container(
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
                  onTap: (){
                    openForProyectTask[keyOpen] = !openForProyectTask[keyOpen];
                    setState(() {});
                  },
                ),
              ],
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

      listTaskRes.add(
          InkWell(
            onTap: () =>clickTarea(task),
            child: Container(
              height: alto * 0.1,
              key: ValueKey("value$index"),
              padding: EdgeInsets.only(top: alto * 0.01,bottom: alto * 0.01),
              color: Colors.white,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: _tareas(task, task.is_priority != 0),
                actions: <Widget>[
                  _buttonSliderAction(task.is_priority == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: Colors.white,size: 30,),Colors.yellow[600],Colors.white,1,task),
                  _buttonSliderAction('COMENTAR',Icon(Icons.message,color: Colors.white,size: 30,),Colors.deepPurple[200],Colors.white,2,task),
                ],
                secondaryActions: <Widget>[
                  _buttonSliderAction('TRABAJANDO',Icon(Icons.build,color: Colors.white,size: 30,),colorSliderTrabajando,Colors.white,3,task),
                  _buttonSliderAction('LISTO',Icon(Icons.check,color: Colors.white,size: 30,),colorSliderListo,Colors.white,4,task),
                ],
              ),
            ),
          )
      );
    }
    return listTaskRes;
  }

  clickTarea(Tarea tarea) async {
    bool res = true;
    if(tarea.name.isEmpty){
      var result  = await Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new AddNameTask(tareaRes: tarea,)));
      res = result as bool;
    }
    if(res){
      Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) =>
          new ChatForTarea(
            tareaRes: tarea,
            listaCasosRes: widget.listaCasosRes,
            blocTaskSend: blocTaskSend,
          )));
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
          //CAMBIAR ESTADO DE DESTACAR 0 = FALSE, 1 = TRUE
          if(tarea.is_priority == 0){ tarea.is_priority = 1;}else{tarea.is_priority = 0;}
          //GUARDAR LOCALMENTE
          if(await TaskDatabaseProvider.db.updateTask(tarea) == 1){
            //AVISAR A PATRONBLOC DE TAREAS ENVIADAS PARA QUE SE ACTUALICE
            blocTaskSend.inList.add(true);
            //ENVIAR A API
            try{
              var result = await conexionHispanos.httpModificarTarea(tarea);
              print('${result.body}');
            }catch(e){
              //SI NO HAY CONEXION GUARDAR EN TABLA LOCAL

            }
          }
        }
      },
    );
  }

  void orderListTaskDeadLine(){
    List<Tarea> listAux = widget.listEnviadosRes;
    Map<int,Tarea> mapTaskAll = {};
    listAux.forEach((task) { mapTaskAll[task.id] = task;});
    listEnviados = [];

    Map<String,List<int>> mapDiffDay = {};
    int pos = 0;
    listAux.forEach((task) {
      if(task.deadline.isNotEmpty){
        Duration diff = DateTime.now().difference(DateTime.parse(task.deadline));
        if(mapDiffDay['${diff.inDays}'] == null){ mapDiffDay['${diff.inDays}'] = [];}
        mapDiffDay['${diff.inDays}'].add(task.id);
        if(diff.inDays > pos){ pos = diff.inDays;}
      }else{
        if(mapDiffDay['vacio'] == null){ mapDiffDay['vacio'] = [];}
        mapDiffDay['vacio'].add(task.id);
      }
    });

    for(int x = 0; x <= pos ; x++){
      if(mapDiffDay['$x'] != null){
        mapDiffDay['$x'].forEach((idTask) {
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

  String getDayDiff(String deadLine){
    String daysLeft = '';
    if(deadLine.isNotEmpty){
      daysLeft = 'Ahora';
      DateTime dateCreate = DateTime.parse(deadLine);
      Duration difDays = DateTime.now().difference(dateCreate);
      if(difDays.inMinutes > 5){
        if(difDays.inMinutes < 60){
          daysLeft = 'Faltan ${difDays.inMinutes} min';
        }else{
          if(difDays.inHours < 24){
            daysLeft = 'Faltan ${difDays.inHours} horas';
          }else{
            double days = difDays.inHours / 24;
            daysLeft = 'Faltan ${days.toStringAsFixed(0)} días';
          }
        }
      }
    }
    return daysLeft;
  }
}