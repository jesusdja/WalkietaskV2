import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Chat/ChatMessenger.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class ChatProjectFirebase{

  final CollectionReference projectFirebase = FirebaseFirestore.instance.collection('Project');

  Future<ChatTareas> createChat(ChatTareas chat) async {
    ChatTareas chatRes;
    try{
      DocumentReference ref = await projectFirebase.add(chat.toJson());
      chat.id = ref.id;
      if(await updateChat(chat)){
        chatRes = chat;
      }
    }catch(ex){
      print(ex.toString());
    }
    return chatRes;
  }

  Future<bool> updateChat(ChatTareas chat) async{
    bool res = false;
    try{
      await projectFirebase.doc(chat.id).update(chat.toJson());
      res = true;
    }catch(ex){
      print(ex.toString());
    }
    return res;
  }

  Future<bool> addMessage(String id, Map<dynamic,dynamic> listMenj2) async{
    bool res = false;
    try{
      await projectFirebase.doc(id).update({'mensajes': listMenj2});
      res = true;
    }catch(ex){
      print(ex.toString());
    }
    return res;
  }

  Future<ChatTareas> checkChat(String id) async{
    ChatTareas res;
    try{
      var result =  await projectFirebase.where('idTarea',isEqualTo: id).get();
      List<ChatTareas> listGrupo = result.docs.map((e) => ChatTareas.fromMap(e.data())).toList();
      if(listGrupo.length != 0){
        res = listGrupo[0];
      }
    }catch(ex){
      print(ex.toString());
    }
    return res;
  }

  Future<ChatTareas> projectBase(Caso project)async{
    ChatTareas chatVery = await checkChat(project.id.toString());
    ChatTareas chatProject;
    if(chatVery != null){
      chatProject = chatVery;
    }else{
      ChatTareas chat = new ChatTareas(
        id: '',
        idTarea: project.id.toString(),
        idUser: project.user_id.toString(),
        idFromUser: project.userprojects,
        mensajes: new Map<String,dynamic>(),
        task: project.toMap(),
      );
      ChatTareas chatTareaNew = await ChatProjectFirebase().createChat(chat);
      if(chatTareaNew != null){
        chatProject = chatTareaNew;
      }else{
        print('NO CREADO');
      }
    }
    return chatProject;
  }


  Future<void> createTaskForProject(int projectId, bool isCreate, int userResponsabilityId, int taskId) async{

    Caso project = await DatabaseProvider.db.getCodeIdCase(projectId.toString());

    //ChatTareas chatProject = await projectBase(project);

    //if(chatProject != null){
      String idMyUser = await SharedPrefe().getValue('unityIdMyUser') ?? '0';
      Tarea task = await DatabaseProvider.db.getCodeIdTask(taskId.toString());

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedHours = DateFormat('kk:mm:ss').format(now);

      Usuario userResponsability = await DatabaseProvider.db.getCodeIdUser(userResponsabilityId.toString());
      Usuario userFrom = await DatabaseProvider.db.getCodeIdUser(idMyUser);

      String message = 'TASKCREATE00:|';
      if(!isCreate){
        message = 'TASKFINALIZE11:|';
      }

      ChatMessenger mensaje = new ChatMessenger(
          fecha: formattedDate,
          hora: formattedHours,
          texto: message,
          from: idMyUser
      );

      //int pos = chatProject.mensajes.length;
      //chatProject.mensajes[pos.toString()] = mensaje.toJson();

      //bool res = await ChatProjectFirebase().addMessage(chatProject.id,chatProject.mensajes);
    //}
  }
}