import 'dart:convert';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteCasos.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';

class UpdateData{

  conexionHttp conexionHispanos = new conexionHttp();

  resetDB() async {
    await  UserDatabaseProvider.db.deleteDatabaseInstance();
    await  TaskDatabaseProvider.db.deleteDatabaseInstance();
    await  CasosDatabaseProvider.db.deleteDatabaseInstance();
    print('BASE DE DATOS LIMPIAS');
  }

  actualizarListaUsuarios(BlocUser blocUser) async {

    bool entre = false;
    //ACTUALIZAR TABLA LOCAL
    try{
      var response = await conexionHispanos.httpListUsuarios();
      var value = jsonDecode(response.body);
      List<dynamic> usuarios = value["users"];
      for(int x = 0; x < usuarios.length; x++){
        Usuario usuario = Usuario.fromJson(usuarios[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Usuario userVery = await  UserDatabaseProvider.db.getCodeId('${usuario.id}');
        if(userVery != null){
          usuario.fijo = userVery.fijo;
          usuario.contact = userVery.contact;
        }
        if(userVery == null || usuario != userVery ){
          entre = true;
          if(userVery == null){
            await UserDatabaseProvider.db.saveUser(usuario);
          }else{
            await UserDatabaseProvider.db.updateUser(usuario);
          }
        }
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR USUARIOS');
    }

    if(entre){
      blocUser.inList.add(true);
    }

    actualizarListaContact(blocUser);
  }

  actualizarListaContact(BlocUser blocUser) async {

    bool entre = false;
    //ACTUALIZAR TABLA LOCAL
    try{
      var response = await conexionHispanos.httpListContacts();
      var value = jsonDecode(response.body);
      List<dynamic> contacts = value["contacts"];
      for(int x = 0; x < contacts.length; x++){
        Usuario contact = Usuario.fromJson(contacts[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Usuario userVery = await  UserDatabaseProvider.db.getCodeId('${contact.id}');
        if(userVery != null){
          userVery.contact = 1;
          await UserDatabaseProvider.db.updateUser(userVery);
          entre = true;
        }
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR CONTACTOS');
    }
    if(entre){
      blocUser.inList.add(true);
    }
  }

  organizarTareas(List<Tarea> lista,BlocTask blocTaskReceived) async {

    try{
      bool entre = false;
      for(int x = 0; x < lista.length; x++){
        Tarea tarea = Tarea.fromJson(lista[x].toJson());
        //EXTRAER VARIABLE DE USUARIO FIJO
        Tarea taskVery = await  TaskDatabaseProvider.db.getCodeId('${tarea.id}');
        if(taskVery == null || tarea != taskVery ) {
          entre = true;
          if (taskVery == null) {
            await TaskDatabaseProvider.db.saveTask(tarea);
          } else {
            await TaskDatabaseProvider.db.updateTask(tarea);
          }
        }
      }
      if(entre){
        blocTaskReceived.inList.add(true);
      }
    }catch(e){
      print('PROBLEMAS AL ORGANIZAR TAREA : ${e.toString()}');
    }

  }

  actualizarListaRecibidos(BlocTask blocTaskReceived) async {
    try{
      var response = await conexionHispanos.httpListTareasRecibidas();
      var value = jsonDecode(response.body);
      List<dynamic> tareas = value["tasks"];
      bool entre = false;
      for(int x = 0; x < tareas.length; x++){
        Tarea tarea = Tarea.fromJson(tareas[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Tarea taskVery = await  TaskDatabaseProvider.db.getCodeId('${tarea.id}');
        if(taskVery == null || tarea != taskVery ) {
          entre = true;
          if (taskVery == null) {
            await TaskDatabaseProvider.db.saveTask(tarea);
          } else {
            tarea.order = taskVery.order;
            await TaskDatabaseProvider.db.updateTask(tarea);
          }
        }
      }
      if(entre){
        blocTaskReceived.inList.add(true);
      }

    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR TAREAS RECIBIDAS');
    }
  }

  actualizarListaEnviados(BlocTask blocTaskSend) async {

    try{
      var response = await conexionHispanos.httpListTareasEnviadas();
      var value = jsonDecode(response.body);
      List<dynamic> tareas = value["tasks"];
      bool entre = false;
      for(int x = 0; x < tareas.length; x++){
        Tarea tarea = Tarea.fromJson(tareas[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Tarea taskVery = await  TaskDatabaseProvider.db.getCodeId('${tarea.id}');

        if(taskVery == null || tarea != taskVery ) {
          entre = true;
          if (taskVery == null) {
            await TaskDatabaseProvider.db.saveTask(tarea);
          } else {
            await TaskDatabaseProvider.db.updateTask(tarea);
          }
        }
      }
      if(entre){
        blocTaskSend.inList.add(true);
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR TAREAS ENVIADAS');
    }
  }

  actualizarCasos(BlocCasos blocCasos) async {
    bool entre = false;
    try{

      var response = await conexionHispanos.httpListCasos();
      var value = jsonDecode(response.body);
      List<dynamic> listcasos = value["projects"];

      for(int x = 0; x < listcasos.length; x++){
        Caso caso = Caso.fromJson(listcasos[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Caso casoVery = await  CasosDatabaseProvider.db.getCodeId('${caso.id}');
        caso.nameCompany = listcasos[x]['customers'] != null ? listcasos[x]['customers']['name'] : '';
        if(casoVery == null || caso != casoVery ) {
          entre = true;
          if (casoVery == null) {
            await CasosDatabaseProvider.db.saveCaso(caso);
          } else {
            await CasosDatabaseProvider.db.updateCaso(caso);
          }
        }
      }
      if(entre){
        blocCasos.inList.add(true);
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR CASOS');
    }
  }

  Future<Usuario> getMyUser() async {
    Usuario user;
    try{
      var response = await conexionHispanos.httpMyUser();
      var value = jsonDecode(response.body);
      user = Usuario.fromMap(value);
    }catch(e){
      print(e.toString());
    }
    return user;
  }
}


