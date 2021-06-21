import 'dart:convert';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocPage.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class UpdateData{

  conexionHttp conexionHispanos = new conexionHttp();

  resetDB() async {
    //await DatabaseProvider.db.deleteDatabaseInstance();
    print('BASE DE DATOS LIMPIAS');
  }

  actualizarListaUsuarios(BlocUser blocUser, BlocCasos blocConection) async {
    print('actualizarListaUsuarios');
    bool entre = false;
    //ACTUALIZAR TABLA LOCAL
    try{
      var response = await conexionHispanos.httpListUsuarios();
      var value = jsonDecode(response.body);
      List<dynamic> usuarios = value["users"];
      for(int x = 0; x < usuarios.length; x++){
        Usuario usuario = Usuario.fromJson(usuarios[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Usuario userVery = await  DatabaseProvider.db.getCodeIdUser('${usuario.id}');
        if(userVery != null){
          usuario.fijo = userVery.fijo;
          usuario.contact = userVery.contact;

          if(usuario.updatedAt.isNotEmpty && userVery.updatedAt.isNotEmpty){
            Duration diff1 = DateTime.parse(usuario.updatedAt).difference(DateTime.now());
            Duration diff2 = DateTime.parse(userVery.updatedAt).difference(DateTime.now());
            usuario.updatedAt = diff1.inSeconds > diff2.inSeconds ? usuario.updatedAt : userVery.updatedAt;
          }else{
            if(userVery.updatedAt.isNotEmpty){
              usuario.updatedAt = userVery.updatedAt;
            }
          }

        }
        if(userVery == null || usuario != userVery ){
          entre = true;
          if(userVery == null){
            await DatabaseProvider.db.saveUser(usuario);
          }else{
            await DatabaseProvider.db.updateUser(usuario);
          }
        }
      }
      if(blocConection != null){blocConection.inList.add(false);}
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR USUARIOS');
      bool conect = await checkConectivity();
      if(blocConection != null){blocConection.inList.add(!conect);}
    }
    if(entre){
      blocUser.inList.add(true);
    }
    actualizarListaContact(blocUser);
  }

  actualizarListaContact(BlocUser blocUser) async {
    print('actualizarListaContact');
    bool entre = false;

    try{
      //ACTUALIZAR TABLA LOCAL
      Map<int,Usuario> mapContactsLocal = {};
      List<Usuario> contactsLocal = await  DatabaseProvider.db.getContactsUser();
      contactsLocal.forEach((element) { mapContactsLocal[element.id] = element; });

      var response = await conexionHispanos.httpListContacts();
      var value = jsonDecode(response.body);
      List<dynamic> contactsHttp = value["contacts"];

      //AGREGAR
      for(int x = 0; x < contactsHttp.length; x++){
        if(mapContactsLocal[contactsHttp[x]['id']] == null){
          await DatabaseProvider.db.updateUserContact(contactsHttp[x]['id'], 1);
          entre = true;
        }
      }
      //ELIMINAR
      List<int> listDelete = [];
      mapContactsLocal.forEach((key, value) {
        bool isHere = false;
        for(int x = 0; x < contactsHttp.length; x++){
          if(key == contactsHttp[x]['id']){
            isHere = true;
          }
        }
        if(!isHere){
          listDelete.add(key);
        }
      });
      for(int x = 0; x < listDelete.length; x++){
        await DatabaseProvider.db.updateUserContact(listDelete[x], 0);
        entre = true;
      }
    }catch(e){
      print(e.toString());
    }
    if(entre){
      blocUser.inList.add(true);
    }
  }

  actualizarListaRecibidos(BlocTask blocTaskReceived, BlocCasos blocConection, {BlocPage blocVerifyFirst}) async {
    print('actualizarListaRecibidos');
    try{
      var response = await conexionHispanos.httpListTareasRecibidas();
      var value = jsonDecode(response.body);
      List<dynamic> tareas = value["tasks"];
      bool entre = false;
      for(int x = 0; x < tareas.length; x++){
        Tarea tarea = Tarea.fromJson(tareas[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Tarea taskVery = await  DatabaseProvider.db.getCodeIdTask('${tarea.id}');
        bool diffTask = false;
        if(taskVery != null){
          Duration diff1 = DateTime.parse(tarea.updated_at).difference(DateTime.now());
          Duration diff2 = DateTime.parse(taskVery.updated_at).difference(DateTime.now());
          diffTask = diff1.inSeconds > diff2.inSeconds;
        }

        if(taskVery == null || tarea != taskVery || diffTask) {
          entre = true;
          if(taskVery != null){
            Duration diff1 = DateTime.parse(tarea.updated_at).difference(DateTime.now());
            Duration diff2 = DateTime.parse(taskVery.updated_at).difference(DateTime.now());
            tarea.updated_at = diff1.inSeconds < diff2.inSeconds ? taskVery.updated_at : tarea.updated_at;
          }

          if (taskVery == null) {
            await DatabaseProvider.db.saveTask(tarea);
          } else {
            tarea.order = taskVery.order;
            await DatabaseProvider.db.updateTask(tarea);
          }
        }

        //******************************
        //VERIFICAR TAREAS NUEVAS
        if(tareas[x]['read'] != null && tareas[x]['read'] == 0 && tareas[x]['finalized'] == 0){
          try{
            List<dynamic> listTaskNew = await SharedPrefe().getValue('notiListTask');
            if (listTaskNew == null) {
              listTaskNew = [];
            }
            List<String> listTaskNewString = [];
            listTaskNew.forEach((element) { listTaskNewString.add(element);});
            listTaskNewString.add(tareas[x]['id'].toString());
            await SharedPrefe().setStringListValue('notiListTask', listTaskNewString);
          }catch(e){
            print(e.toString());
          }
        }
      }

      if(entre){
        blocTaskReceived.inList.add(true);
      }
      blocConection.inList.add(false);
      if(blocVerifyFirst != null){
        blocVerifyFirst.inList.add(1);
      }
    }catch(e){
      bool conect = await checkConectivity();
      if(blocConection != null){blocConection.inList.add(!conect);}
      print('SIN CONEXION PARA ACTUALIZAR TAREAS RECIBIDAS');
    }
  }

  actualizarListaEnviados(BlocTask blocTaskSend, BlocCasos blocConection) async {
    print('actualizarListaEnviados');
    try{
      var response = await conexionHispanos.httpListTareasEnviadas();
      var value = jsonDecode(response.body);
      List<dynamic> tareas = value["tasks"];
      bool entre = false;
      for(int x = 0; x < tareas.length; x++){
        Tarea tarea = Tarea.fromJson(tareas[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Tarea taskVery = await  DatabaseProvider.db.getCodeIdTask('${tarea.id}');
        bool diffTask = false;
        if(taskVery != null){
          Duration diff1 = DateTime.parse(tarea.updated_at).difference(DateTime.now());
          Duration diff2 = DateTime.parse(taskVery.updated_at).difference(DateTime.now());
          diffTask = diff1.inSeconds > diff2.inSeconds;
        }
        if(taskVery == null || tarea != taskVery || diffTask) {
          entre = true;
          if(taskVery != null){
            Duration diff1 = DateTime.parse(tarea.updated_at).difference(DateTime.now());
            Duration diff2 = DateTime.parse(taskVery.updated_at).difference(DateTime.now());
            tarea.updated_at = diff1.inSeconds < diff2.inSeconds ? taskVery.updated_at : tarea.updated_at;
          }
          if (taskVery == null) {
            await DatabaseProvider.db.saveTask(tarea);
          } else {
            await DatabaseProvider.db.updateTask(tarea);
          }
        }
      }
      if(entre){
        blocTaskSend.inList.add(true);
      }
      if(blocConection != null){blocConection.inList.add(false);}
    }catch(e){
      bool conect = await checkConectivity();
      if(blocConection != null){blocConection.inList.add(!conect);}
      print('SIN CONEXION PARA ACTUALIZAR TAREAS ENVIADAS');
    }
  }

  actualizarListaTareasPorProyecto(BlocTask blocTaskForProject) async {
    print('actualizarListaTareasPorProyecto');
    try{
      var response = await conexionHispanos.httpListTareasPorProyecto();
      var value = jsonDecode(response.body);
      List<dynamic> tareas = value["tasks"];
      bool entre = false;
      for(int x = 0; x < tareas.length; x++){
        Tarea tarea = Tarea.fromJson(tareas[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        Tarea taskVery = await  DatabaseProvider.db.getCodeIdTask('${tarea.id}');
        bool diffTask = false;
        if(taskVery != null){
          Duration diff1 = DateTime.parse(tarea.updated_at).difference(DateTime.now());
          Duration diff2 = DateTime.parse(taskVery.updated_at).difference(DateTime.now());
          diffTask = diff1.inSeconds > diff2.inSeconds;
        }

        if(taskVery == null || tarea != taskVery || diffTask) {
          entre = true;
          if(taskVery != null){
            Duration diff1 = DateTime.parse(tarea.updated_at).difference(DateTime.now());
            Duration diff2 = DateTime.parse(taskVery.updated_at).difference(DateTime.now());
            tarea.updated_at = diff1.inSeconds < diff2.inSeconds ? taskVery.updated_at : tarea.updated_at;
          }

          if (taskVery == null) {
            await DatabaseProvider.db.saveTask(tarea);
          } else {
            tarea.order = taskVery.order;
            await DatabaseProvider.db.updateTask(tarea);
          }
        }
      }

      if(entre){
        blocTaskForProject.inList.add(true);
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR TAREAS POR PROYECTO');
    }
  }

  actualizarCasos(BlocCasos blocCasos) async {
    print('actualizarCasos');
    bool entre = false;


    List<dynamic> listcasos = [];
    try{
      var response = await conexionHispanos.httpListMyProjects();
      var value = jsonDecode(response.body);
      listcasos = value["projects"];

      for(int x = 0; x < listcasos.length; x++){
        Caso caso = Caso.fromJson(listcasos[x]);
        caso.nameCompany = 'false';
        String usersForProject = '';
        if(listcasos[x]['userprojects'] != null){
          String idUser = await SharedPrefe().getValue('unityIdMyUser');
          for(int x1 = 0; x1 < listcasos[x]['userprojects'].length; x1++){
            usersForProject = '$usersForProject${listcasos[x]['userprojects'][x1]['user_id']}|';
            if('${listcasos[x]['userprojects'][x1]['user_id']}' == '$idUser'){
              caso.nameCompany = 'true';
            }
          }
        }
        caso.userprojects = usersForProject;
        //EXTRAER VARIABLE DE USUARIO FIJO
        Caso casoVery = await  DatabaseProvider.db.getCodeIdCase('${caso.id}');
        //caso.nameCompany = listcasos[x]['customers'] != null ? listcasos[x]['customers']['name'] : '';
        caso.is_priority = casoVery == null ? 0 : casoVery.is_priority ?? 0;

        if(caso != casoVery ){
          entre = true;

          DateTime dateCaso = DateTime.parse(caso.updated_at);
          DateTime dateCasoVery = casoVery != null ? DateTime.parse(casoVery.updated_at) : null;
          if(casoVery != null && dateCasoVery.isAfter(dateCaso)){
            caso.updated_at = casoVery.updated_at;
          }

          if (casoVery == null) {
            await DatabaseProvider.db.saveCase(caso);
          } else {
            await DatabaseProvider.db.updateCase(caso);
          }
        }
      }
      if(entre){
        blocCasos.inList.add(true);
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR CASOS');
    }

    try{
      List<Caso> projectLocal = await DatabaseProvider.db.getAllCase();
      for(int x = 0; x < projectLocal.length; x++){
        bool exist = false;
        for(int x2 = 0; x2 < listcasos.length; x2++){
          if(projectLocal[x].id == listcasos[x2]["id"]){
            exist = true;
          }
        }
        if(!exist){
          await DatabaseProvider.db.deleteProjectCase(projectLocal[x].id);
        }
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR CASOS LOCAL');
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

  actualizarListaInvitationSent(BlocCasos blocInvitation, BlocCasos blocConection) async {
    print('actualizarListaInvitationSent');
    bool entre = false;
    //ACTUALIZAR TABLA LOCAL
    try{
      var response = await conexionHispanos.httpListInvitationSent();
      var value = jsonDecode(response.body);
      List<dynamic> invitations = value["contacts"];
      for(int x = 0; x < invitations.length; x++){
        InvitationModel invitation = InvitationModel.fromJson(invitations[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        InvitationModel invitationVery = await  DatabaseProvider.db.getCodeIdInvitation('${invitation.id}');
        invitation.inv = 0;
        if(invitationVery == null || invitation != invitationVery ){
          entre = true;
          if(invitationVery == null){
            await DatabaseProvider.db.saveInvitation(invitation);
          }else{
            await DatabaseProvider.db.updateInvitation(invitation);
          }
        }
      }

      try{
        List<InvitationModel> invitationsLocal = await  DatabaseProvider.db.getAllInvitation();
        for(int x =0; x < invitationsLocal.length; x++){
          bool exist = false;
          for(int y =0; y < invitations.length; y++){
            if(invitationsLocal[x].id == invitations[y]['id']){
              exist = true;
            }
          }
          if(!exist){
            await  DatabaseProvider.db.deleteInvitation(invitationsLocal[x].id);
          }
        }
        if(blocConection != null){blocConection.inList.add(false);}
      }catch(e){
        bool conect = await checkConectivity();
        if(blocConection != null){blocConection.inList.add(!conect);}
        print('SIN CONEXION PARA ACTUALIZAR INVITACIONES ENVIADAS II');
      }
      if(blocConection != null){blocConection.inList.add(false);}
    }catch(e){
      bool conect = await checkConectivity();
      if(blocConection != null){blocConection.inList.add(!conect);}
      print('SIN CONEXION PARA ACTUALIZAR INVITACIONES ENVIADAS');
    }
    if(entre){
      blocInvitation.inList.add(true);
    }
  }

  actualizarListaInvitationReceived(BlocCasos blocInvitation, BlocCasos blocConection, {BlocPage blocVerifyFirst}) async {
    print('actualizarListaInvitationReceived');
    bool entre = false;
    //ACTUALIZAR TABLA LOCAL
    try{
      var response = await conexionHispanos.httpListInvitationReceived();
      var value = jsonDecode(response.body);
      List<dynamic> invitations = value["contacts"];
      for(int x = 0; x < invitations.length; x++){
        InvitationModel invitation = InvitationModel.fromJson(invitations[x]);
        //EXTRAER VARIABLE DE USUARIO FIJO
        InvitationModel invitationVery = await  DatabaseProvider.db.getCodeIdInvitation('${invitation.id}');
        invitation.inv = 1;
        if(invitationVery == null || invitation != invitationVery ){
          entre = true;
          if(invitationVery == null){
            await DatabaseProvider.db.saveInvitation(invitation);
          }else{
            await DatabaseProvider.db.updateInvitation(invitation);
          }
        }
        if(invitations[x]['read'] == 0){
          await SharedPrefe().setBoolValue('notiContacts', true);
          await SharedPrefe().setBoolValue('notiContacts_received', true);
        }
      }

      try{
        List<InvitationModel> invitationsLocal = await  DatabaseProvider.db.getAllInvitation();
        for(int x =0; x < invitationsLocal.length; x++){
          bool exist = false;
          for(int y =0; y < invitations.length; y++){
            if(invitationsLocal[x].id == invitations[y]['id']){
              exist = true;
            }
          }
          if(!exist){
            await  DatabaseProvider.db.deleteInvitation(invitationsLocal[x].id);
          }
        }
        if(blocConection != null){blocConection.inList.add(false);}
      }catch(e){
        bool conect = await checkConectivity();
        if(blocConection != null){blocConection.inList.add(!conect);}
        print('SIN CONEXION PARA ACTUALIZAR INVITACIONES RECIBIDAS II');
      }
      if(blocConection != null){blocConection.inList.add(false);}
    }catch(e){
      bool conect = await checkConectivity();
      if(blocConection != null){blocConection.inList.add(!conect);}
      print('SIN CONEXION PARA ACTUALIZAR INVITACIONES RECIBIDAS');
    }
    if(entre){
      blocInvitation.inList.add(true);
    }
    if(blocVerifyFirst != null){
      blocVerifyFirst.inList.add(1);
    }
  }

  Future<List<Map<String,dynamic>>> getNotifications() async {
    List<Map<String,dynamic>> notifications = [];
    try{
      var response = await conexionHispanos.httpMyNotifications();
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        List noti = value['notifications'] as List;
        noti.forEach((element) {
          Map<String,dynamic> map = element as Map<String,dynamic>;
          notifications.add(map);
        });
      }
    }catch(e){
      print('getNotifications: ${e.toString()}');
    }
    return notifications;
  }
}


