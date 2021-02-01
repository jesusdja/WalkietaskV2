import 'dart:convert';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Globales.dart';

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
    //ACTUALIZAR TABLA LOCAL
    Map<int,Usuario> mapContactsLocal = {};
    try{
      List<Usuario> contactsLocal = await  DatabaseProvider.db.getContactsUser();
      for(int x =0; x < contactsLocal.length; x++){
        Usuario contact = contactsLocal[x];
        contact.contact = 0;
        mapContactsLocal[contact.id] = contact;
        await DatabaseProvider.db.updateUser(contact);
      }

      var response = await conexionHispanos.httpListContacts();
      var value = jsonDecode(response.body);
      List<dynamic> contacts = value["contacts"];
      for(int x = 0; x < contacts.length; x++){
        Usuario contact = Usuario.fromJson(contacts[x]);
        contact.contact = 1;
        contact.fijo = mapContactsLocal[contact.id] == null ? 0 : mapContactsLocal[contact.id].fijo;
        mapContactsLocal[contact.id] = contact;
      }
    }catch(e){
      print('SIN CONEXION PARA ACTUALIZAR CONTACTOS');
    }
    for(int x = 0; x < mapContactsLocal.length; x++){
      Usuario user = mapContactsLocal[mapContactsLocal.keys.elementAt(x)];
      if(user.contact == 1){
        entre = true;
        await DatabaseProvider.db.updateUser(user);
      }
    }
    if(entre){
      blocUser.inList.add(true);
    }
  }

  organizarTareas(List<Tarea> lista,BlocTask blocTaskReceived) async {
    print('organizarTareas');
    try{
      bool entre = false;
      for(int x = 0; x < lista.length; x++){
        Tarea tarea = Tarea.fromJson(lista[x].toJson());
        //EXTRAER VARIABLE DE USUARIO FIJO
        Tarea taskVery = await  DatabaseProvider.db.getCodeIdTask('${tarea.id}');
        if(taskVery == null || tarea != taskVery ) {
          entre = true;
          if (taskVery == null) {
            await DatabaseProvider.db.saveTask(tarea);
          } else {
            await DatabaseProvider.db.updateTask(tarea);
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

  actualizarListaRecibidos(BlocTask blocTaskReceived, BlocCasos blocConection) async {
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
        if(taskVery == null || tarea != taskVery ) {
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

      List<Tarea> listRecibida = await DatabaseProvider.db.getAllRecevidTask();
      for(int x = 0; x < listRecibida.length; x++){
        bool existTask = false;
        for(int xx = 0; xx < tareas.length; xx++){
          if(listRecibida[x].id == tareas[xx]['id']){
            existTask = true;
          }
        }
        if(!existTask){
          entre = true;
          Tarea taskUpdate = listRecibida[x];
          taskUpdate.finalized = 1;
          await DatabaseProvider.db.deleteTaskId(taskUpdate.id);
        }
      }

      if(entre){
        blocTaskReceived.inList.add(true);
      }
      blocConection.inList.add(false);
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

        if(taskVery == null || tarea != taskVery ) {
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

      List<Tarea> listEnviados = await DatabaseProvider.db.getAllSendTask();
      for(int x = 0; x < listEnviados.length; x++){
        bool existTask = false;
        for(int xx = 0; xx < tareas.length; xx++){
          if(listEnviados[x].id == tareas[xx]['id']){
            existTask = true;
          }
        }
        if(!existTask){
          entre = true;
          Tarea taskUpdate = listEnviados[x];
          taskUpdate.finalized = 1;
          await DatabaseProvider.db.deleteTaskId(taskUpdate.id);
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
        //EXTRAER VARIABLE DE USUARIO FIJO
        Caso casoVery = await  DatabaseProvider.db.getCodeIdCase('${caso.id}');
        caso.nameCompany = listcasos[x]['customers'] != null ? listcasos[x]['customers']['name'] : '';
        if(casoVery == null || caso != casoVery ) {
          entre = true;
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

  actualizarListaInvitationReceived(BlocCasos blocInvitation, BlocCasos blocConection) async {
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
  }
}


