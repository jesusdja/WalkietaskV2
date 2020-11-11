import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';

class ChatTareaFirebase{

  final CollectionReference tareasColeccion = Firestore.instance.collection('Tareas');

  Future<ChatTareas> crearTareaChat(ChatTareas chat) async {
    ChatTareas chatRes;
    try{
      DocumentReference ref = await tareasColeccion.add(chat.toJson());
      chat.id = ref.documentID;
      if(await modificarTareaChat(chat)){
        chatRes = chat;
      }
    }catch(ex){
      print(ex.toString());
    }
    return chatRes;
  }

  Future<bool> modificarTareaChat(ChatTareas chat) async{
    bool res = false;
    try{
      await tareasColeccion.document(chat.id).updateData(chat.toJson());
      res = true;
    }catch(ex){
      print(ex.toString());
    }
    return res;
  }
  Future<bool> agregarMensaje(String id, Map<dynamic,dynamic> listMenj2) async{
    bool res = false;
    try{
      await tareasColeccion.document(id).updateData({'mensajes': listMenj2});
      res = true;
    }catch(ex){
      print(ex.toString());
    }
    return res;
  }

  Future<ChatTareas> verificarExistencia(String id) async{
    ChatTareas res;
    try{
      var result =  await tareasColeccion.where('idTarea',isEqualTo: id).getDocuments();
      List<ChatTareas> listGrupo = result.documents.map((doc) => ChatTareas.fromMap(doc.data)).toList();
      if(listGrupo.length != 0){
        res = listGrupo[0];
      }
    }catch(ex){
      print(ex.toString());
    }
    return res;
  }

//  Future<bool> crearMensaje(String idGrupo) async {
//    bool res = false;
//    ChatModels chatM = new ChatModels(
//      id: '',
//      idgrupo: idGrupo,
//      mensajes: new Map<String,dynamic>()
//    );
//    res = await dbMensaje.crearChat(chatM);
//    return res;
//  }

//  Future<List<Grupo>> obtenerTodosGrupos() async{
//    List<Grupo> listGrupo = new List<Grupo>();
//    var query1 = await gruposColeccion.getDocuments();
//    listGrupo = query1.documents.map((doc) => Grupo.fromMap(doc.data)).toList();
//    return listGrupo;
//  }


//
//  Future<bool> eliminarGrupo(String id) async{
//    bool res = false;
//    try{
//      await gruposColeccion.document(id).delete();
//      res = true;
//    }catch(ex){
//      print(ex.toString());
//    }
//    return res;
//  }
}

