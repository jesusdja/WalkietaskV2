import 'dart:io';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/main.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

//String avatarImage = 'http://www.nabu.me.php72-7.phx1-1.websitetestlink.com/uploads/system/avatar.png';
Widget avatarWidget({@required double alto, @required String text, double radius = 0.03}){
  return CircleAvatar(
    backgroundColor: WalkieTaskColors.color_76ADE3,
    radius: alto * radius,
    child: Padding(
      padding: EdgeInsets.all(alto * 0.003),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: alto * radius,
        child: Center(child: Text(text ?? '', style: WalkieTaskStyles().stylePrimary(color: WalkieTaskColors.color_76ADE3,size: alto * (radius - 0.007), fontWeight: FontWeight.bold),)),
      ),
    ),
  );
}
Widget avatarWidgetProject({@required double alto, @required String text, double radius = 0.03}){
  return CircleAvatar(
    backgroundColor: WalkieTaskColors.color_8CD59B,
    radius: alto * radius,
    child: Padding(
      padding: EdgeInsets.all(alto * 0.003),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: alto * radius,
        child: Center(child: Text(text ?? '', style: WalkieTaskStyles().stylePrimary(color: WalkieTaskColors.color_8CD59B,size: alto * (radius - 0.007), fontWeight: FontWeight.bold),)),
      ),
    ),
  );
}
Widget avatarWidgetImage({@required double alto, @required String pathImage, double radius = 0.03}){
  return Container(
    child: CircleAvatar(
      radius: alto * radius,
      backgroundImage: Image.network(pathImage).image,
    ),
  );
}

Widget avatarWidgetImageLocal({@required double alto, @required String pathImage, double radius = 0.03}){
  return Container(
    child: CircleAvatar(
      radius: alto * radius,
      backgroundImage: Image.asset(pathImage).image,
    ),
  );
}

Future<String> obtenerToken() async {

  String token  = await SharedPrefe().getValue('unityToken');
  return token;
}

String translate({@required BuildContext context, @required String text}){
  return AppLocalizations.of(context).translate(text);
}

Future<bool> checkConectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return true;
    }
  } on SocketException catch (_) {
    print('not connected');
  }
  return false;
}

Future<void> addPopTask(int num) async {
  try{
    int pop = await SharedPrefe().getValue('popValueTask') ?? 0;
    pop = pop + num;
    await SharedPrefe().setIntValue('popValueTask', pop);
  }catch(e){
    print(e.toString());
  }
}

Future<Image> getPhotoUser() async {
  String pathPhoto = await SharedPrefe().getValue('WalkiephotoUser') ?? '';
  Image photo;
  if(pathPhoto != null && pathPhoto.isNotEmpty){
    photo = Image.file(File(pathPhoto));
  }
  return photo;
}

Future<List> getListDataHome({@required List<Usuario> listaUser,@required List<Caso> listProjects,}) async {
  List<Map<String,dynamic>> mapAll = [];
  List<Map<String,dynamic>> mapAllAux = [];
  List listWidgetsHome = [];

  List<Tarea> listR = await DatabaseProvider.db.getTaskWithProjects();
  List<Tarea> listR2 = await DatabaseProvider.db.getAssignedTaskWithProjects();

  try{
    //AGREGAR USUARIOS DATA HOME
    listaUser.forEach((element) {
      mapAll.add({'info' : element,'type' : 'user','date' : element.updatedAt});
      mapAllAux.add({'info' : element,'type' : 'user','date' : element.updatedAt});
    });


    //OBTENER TAREAS CON PROYECTO
    Map<int,List<Tarea>> mapTaskWithProject = {};
    listR.forEach((element) {
      int idProject = element.project_id ?? 0;
      if(mapTaskWithProject[idProject] == null){ mapTaskWithProject[idProject] = [];}
      mapTaskWithProject[idProject].add(element);
    });
    //OBTENER MIS TAREAS CON PROYECTO
    Map<int,List<Tarea>> mapAssignedTaskWithProject = {};
    listR2.forEach((element) {
      int idProject = element.project_id ?? 0;
      if(mapAssignedTaskWithProject[idProject] == null){ mapAssignedTaskWithProject[idProject] = [];}
      mapAssignedTaskWithProject[idProject].add(element);
    });
    //AGREGAR PROYECTOS DATA HOME
    for(int x = 0; x < listProjects.length; x++){
      Caso element = listProjects[x];

      List<Tarea> cantTaskToProject = [];
      if(mapTaskWithProject[element.id] != null){
        cantTaskToProject = mapTaskWithProject[element.id];
      }
      List<Tarea> cantTaskAssigned = [];
      if(mapAssignedTaskWithProject[element.id] != null){
        cantTaskAssigned = mapAssignedTaskWithProject[element.id];
      }

      String photoProjectAvatar = await SharedPrefe().getValue('${element.id}Photo');

      mapAll.add({ 'info' : element, 'type' : 'project', 'date' : element.updated_at, 'cantTaskAssigned' : cantTaskAssigned, 'cantTaskToProject' : cantTaskToProject, 'photoProjectAvatar' : photoProjectAvatar});
      mapAllAux.add({ 'info' : element, 'type' : 'project', 'date' : element.updated_at, 'cantTaskAssigned' : cantTaskAssigned, 'cantTaskToProject' : cantTaskToProject, 'photoProjectAvatar' : photoProjectAvatar});
    }
    //UNIR USUARIO Y PROYECTO AL HOME
    if(mapAll.isNotEmpty){
      List listWidgetsHomeAux = [];
      for(int j = 0; j < mapAll.length; j++){
        String dateStrg = mapAllAux[0]['date'] == '' ? DateTime.now().toString() : mapAllAux[0]['date'];
        DateTime dateOne = DateTime.parse(dateStrg);
        int pos = 0;
        for(int x1 = 0; x1 < mapAllAux.length; x1++){
          String dateStrg2 = mapAllAux[x1]['date'] == '' ? DateTime.now().toString() : mapAllAux[x1]['date'];
          DateTime dateTwo = DateTime.parse(dateStrg2);
          if(dateTwo.isAfter(dateOne)){
            pos = x1;
          }
        }
        listWidgetsHomeAux.add(mapAllAux[pos]);
        mapAllAux.removeAt(pos);
      }


      listWidgetsHomeAux.forEach((element) {
        if(element['type'] == 'user' && element['info'].fijo == 1){
          listWidgetsHome.add(element);
        }
        if(element['type'] == 'project' && element['info'].is_priority == 1){
          listWidgetsHome.add(element);
        }
      });
      listWidgetsHomeAux.forEach((element) {
        if(element['type'] == 'user' && element['info'].fijo == 0){
          listWidgetsHome.add(element);
        }
        if(element['type'] == 'project' && element['info'].is_priority == 0){
          listWidgetsHome.add(element);
        }
      });
    }
  }catch(e){
    print('_inicializarDataHome: ${e.toString()}');
  }

  return listWidgetsHome;
}






