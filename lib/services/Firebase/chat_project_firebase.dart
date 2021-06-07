import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';

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
}