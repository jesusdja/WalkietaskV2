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

class ListadoTareasEnviadas extends StatefulWidget {

  ListadoTareasEnviadas({this.listEnviadosRes,this.mapIdUserRes,this.blocTaskSendRes,this.listaCasosRes});
  List<Tarea> listEnviadosRes;
  final Map<int,Usuario> mapIdUserRes;
  final BlocTask blocTaskSendRes;
  final List<Caso> listaCasosRes;

  @override
  _ListadoTareasState createState() => _ListadoTareasState();
}

class _ListadoTareasState extends State<ListadoTareasEnviadas> {

  Map<int,bool> mapAppBar = {0:true,1:false,2:false};
  bool valueSwitch = true;

  List<Tarea> listEnviados;
  Map<int,Usuario> mapIdUser;
  Map<int,Caso> mapCasos = {};

  double alto = 0;
  double ancho = 0;

  BlocTask blocTaskSend;

  conexionHttp conexionHispanos = new conexionHttp();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blocTaskSend = widget.blocTaskSendRes;
    _inicializar();
    widget.listaCasosRes.forEach((element) { mapCasos[element.id] = element;});
  }

  _inicializar(){
    listEnviados = widget.listEnviadosRes;
    mapIdUser = widget.mapIdUserRes;
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
                mapAppBar[1] ? _listado() : Container(),
                mapAppBar[2] ? _listado() : Container(),
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
            //_updateMyItems(oldIndex, newIndex);
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

    String proyectName = '(Sin proyecto asignado)';
    if(tarea.project_id != null && tarea.project_id != 0){
      proyectName = mapCasos[tarea.project_id].name;
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
  clickTarea(Tarea tarea){
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new ChatForTarea(tareaRes: tarea,listaCasosRes: widget.listaCasosRes,)));
  }

  Widget _tareasPorUser(List<Tarea> listTareas){
    return Container(
      height: (alto * 0.1006) * listTareas.length,
      child: ListView.builder(
        itemCount: listTareas.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context,index){
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Container(
              color: index % 2 != 0 ? Colors.white : Colors.grey[100],
              height: alto * 0.1,
              child: listTareas[index].is_priority == 1 ?
              _tareasFavoritas(listTareas[index])
                  :
              _tareasDeUsu(listTareas[index]),
            ),
            actions: <Widget>[
              _ButtonSliderAction(listTareas[index].is_priority == 1 ? 'OLVIDAR' : 'DESTACAR',Icon(Icons.star,color: Colors.white,size: 30,),Colors.yellow[600],Colors.white,1,listTareas[index]),
              _ButtonSliderAction('COMENTAR',Icon(Icons.message,color: Colors.white,size: 30,),Colors.deepPurple[200],Colors.white,2,listTareas[index]),
            ],
            secondaryActions: <Widget>[
              _ButtonSliderAction('TRABAJANDO',Icon(Icons.build,color: Colors.white,size: 30,),colorSliderTrabajando,Colors.white,3,listTareas[index]),
              _ButtonSliderAction('LISTO',Icon(Icons.check,color: Colors.white,size: 30,),colorSliderListo,Colors.white,4,listTareas[index]),
            ],
          );
        },
      ),
    );
  }

  Widget _tareasFavoritas(Tarea tarea){

    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(mapIdUser[tarea.user_id] != null && mapIdUser[tarea.user_id].avatar != ''){
        avatarUser = Image.network('$directorioImage${mapIdUser[tarea.user_id].avatar}');
      }
    }

    return InkWell(
      onTap: () =>clickTarea(tarea),
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              width: ancho * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      width: ancho * 0.2,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(3.0), // borde width
                          decoration: new BoxDecoration(
                            color: bordeCirculeAvatar, // border color
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 11,
                            backgroundImage: avatarUser.image,
                            //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                          ),
                        ),
                      ),
                    ),
                    flex: 2,
                  ),
                  Flexible(
                      flex: 1,
                      child: Icon(Icons.star,color: Colors.yellow[600],size: alto * 0.035,)
                  ),
                ],
              ),
            ),
            Container(
              width: ancho * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(mapIdUser[tarea.user_id] == null ? '' : mapIdUser[tarea.user_id].name,
                    style: estiloLetras(alto * 0.02,Colors.grey[600],),),
                  SizedBox(height: alto * 0.006,),
                  Text(tarea.name,
                    style: estiloLetras(alto * 0.018,Colors.grey[600]),)
                ],
              ),
            ),
            Container(
              width: ancho * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Hace 2 días',style: estiloLetras(alto * 0.018, Colors.grey[600]),),
                ],
              ),
            ),
            Container(
              width: ancho * 0.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.message,color: Colors.grey[600],size: alto * 0.03),
                  SizedBox(height: alto * 0.02,),
                  tarea.url_audio != '' ? Icon(Icons.volume_up,color:  Colors.grey[600],size: alto * 0.03,) : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tareasDeUsu(Tarea tarea){
    Image avatarUser = Image.network(avatarImage);
    if(mapIdUser != null){
      if(mapIdUser[tarea.user_id] != null && mapIdUser[tarea.user_id].avatar != ''){
        avatarUser = Image.network('$directorioImage${mapIdUser[tarea.user_id].avatar}');
      }
    }
    return InkWell(
      onTap: () =>clickTarea(tarea),
      child: Center(
        child: Row(
          children: <Widget>[
            Container(
              width: ancho * 0.85,
              height: alto * 0.1,
              padding: EdgeInsets.only(left: ancho * 0.1,top: alto * 0.015),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Hace 7 días'
                      ,style: estiloLetras(alto * 0.02,Colors.grey[600]),),
                    SizedBox(height: alto * 0.01,),
                    Text('${tarea.name}',
                      style: estiloLetras(alto * 0.02,Colors.grey[600]),),
                  ],
                ),
              ),
            ),
            Container(
              width: ancho * 0.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.message,color: Colors.grey[500],size: alto * 0.03),
                  SizedBox(height: alto * 0.02,),
                  tarea.url_audio != '' ? Icon(Icons.volume_up,color:  Colors.grey[600],size: alto * 0.03,) : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}