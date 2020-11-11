import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';

class ListadoTareasEnviadas extends StatefulWidget {

  ListadoTareasEnviadas({this.listEnviadosRes,this.mapIdUserRes,this.blocTaskSendRes,this.listaCasosRes});
  final Map<int,List<Tarea>> listEnviadosRes;
  final Map<int,Usuario> mapIdUserRes;
  final BlocTask blocTaskSendRes;
  final List<Caso> listaCasosRes;

  @override
  _ListadoTareasState createState() => _ListadoTareasState();
}

class _ListadoTareasState extends State<ListadoTareasEnviadas> {

  Map<int,List<Tarea>> listEnviados;
  Map<int,Usuario> mapIdUser;

  double alto = 0;
  double ancho = 0;

  Map<int,bool> abrirMenu = new Map<int,bool>();
  BlocTask blocTaskSend;

  conexionHttp conexionHispanos = new conexionHttp();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blocTaskSend = widget.blocTaskSendRes;
    _inicializar();
    abrirMenu[0] = false;
    listEnviados.forEach((key,value){
      abrirMenu[key] = false;
    });
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


  _contenido(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //listaDestacados != null ? _destacados() : Container(),
                Container(
                  color: Colors.white,
                  height: alto * 0.07,
                  width: ancho * 0.9,
                  child: Center(
                    child: Container(
                      width: ancho * 0.9,
                      child: Text('Tareas',style: estiloLetras(alto * 0.03,Colors.grey[600]),textAlign: TextAlign.left,),
                    ),
                  ),
                ),
                _listado(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _listado(){
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