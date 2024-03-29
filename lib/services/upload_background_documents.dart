import 'dart:convert';
import 'dart:io';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/services/AWS.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Firebase/chat_project_firebase.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

Future<void> uploadBackDocuments(BlocProgress blocIndicatorProgress) async {

  List<dynamic> listDocuments = await SharedPrefe().getValue('WalListDocument') ?? [];

  String myUser = await SharedPrefe().getValue('unityIdMyUser') ?? '';
  conexionHttp connectionHttp = new conexionHttp();

  print('SUBIENDO ${listDocuments.length} documentos.');

  for(int x = 0; x < listDocuments.length; x++){

    //id integrante | titulo | path audio | id caso | descripcion | fecha | path adjunto
    List data = listDocuments[x].split('|');
    blocIndicatorProgress.inList.add({'progressIndicator' : 0.1, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});
    Map jsonBody = {
      'reminder_type_id': '1',
      'user_id': myUser,
      'status_id' : '1',
    };
    blocIndicatorProgress.inList.add({'progressIndicator' : 0.2, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});

    if(data.length > 0 && data[0] != ''){  jsonBody['user_responsability_id'] = data[0] == '0' ? myUser : data[0]; }

    if(data.length > 1 && data[1] != ''){  jsonBody['name'] = data[1]; }

    if(data.length > 2 && data[2] != ''){ jsonBody['url_audio'] = data[2]; }

    blocIndicatorProgress.inList.add({'progressIndicator' : 0.3, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});

    if(data.length > 3 && data[3] != '' && data[3] != '0'){  jsonBody['project_id'] = data[3]; }
    if(data.length > 4 && data[4] != ''){  jsonBody['description'] = data[4]; }

    blocIndicatorProgress.inList.add({'progressIndicator' : 0.4, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});

    if(data.length > 5 && data[5] != ''){  jsonBody['deadline'] = data[5]; }

    if(data.length > 6 && data[6] != ''){ jsonBody['url_attachment'] = data[6]; }

    blocIndicatorProgress.inList.add({'progressIndicator' : 0.5, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});

    try{
      var response = await connectionHttp.httpCrearTarea(jsonBody);
      //await Future.delayed(Duration(seconds: 3));
      blocIndicatorProgress.inList.add({'progressIndicator' : 0.8, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});
      var value = jsonDecode(response.body);
      //await Future.delayed(Duration(seconds: 3));
      blocIndicatorProgress.inList.add({'progressIndicator' : 0.9, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});
      if(value['status_code'] == 201){

        ChatProjectFirebase().createTaskForProject(value['project_id'], true, value['user_responsability_id'], 0);

        print('CREADO - ${data[1]}');
      }else{
        print('NO CREADO - ${data[1]}');
      }

      //ELIMINAR AUDIO
      final file = File(data[2]);
      file.openRead();
      bool exist = await file.exists();
      if(exist){
        await File(data[2]).delete();
        print('SE ELIMINO EL AUDIO');
      }
      //ELIMINAR TAREA DE LISTA
      List<String> listDocumentsNoSend = [];
      for(int x1 = 0; x1 < listDocuments.length; x1++){
        if(x != x1){ listDocumentsNoSend.add(listDocuments[x]); }
      }
      await SharedPrefe().setStringListValue('WalListDocument',listDocumentsNoSend);
      await Future.delayed(Duration(seconds: 1));
      blocIndicatorProgress.inList.add({
        'progressIndicator' : 1,
        'viewIndicatorProgress' : true,
        'cant' : (listDocuments.length - x),
        'error' : value['status_code'] == 500,
        'errorMessage' : value['message'] ?? 'Error al enviar tarea'
      });

    }catch(e){
      print(e.toString());
      print('NO CREADO - ${data[1]}');
      await Future.delayed(Duration(seconds: 1));
      blocIndicatorProgress.inList.add({'progressIndicator' : 1, 'viewIndicatorProgress' : true, 'cant' : (listDocuments.length - x)});
    }

    await Future.delayed(Duration(seconds: 2));
    blocIndicatorProgress.inList.add({'progressIndicator' : 0, 'viewIndicatorProgress' : false, 'cant' : (listDocuments.length - x)});

  }
}

Future<void> uploadBackPhotoProjects() async {

  List<dynamic> listDocuments = await SharedPrefe().getValue('WalListPhotosProjects') ?? [];

  //conexionHttp connectionHttp = new conexionHttp();

  print('SUBIENDO ${listDocuments.length} FOTO PROYECTO.');

  for(int x = 0; x < listDocuments.length; x++){

    //id integrante | path |
    List data = listDocuments[x].split('|');

    try{
      var response = await conexionHttp().httpSendImageProject(data[1],data[0]);
      if(response.statusCode == 200){
        List<String> listDocumentsNoSend = [];
        for(int x1 = 0; x1 < listDocuments.length; x1++){
          if(x != x1){
            listDocumentsNoSend.add(listDocuments[x]);
            print('ELIMINADO ${listDocuments[x]} - FOTO PROYECTO.');
          }
        }
        await SharedPrefe().setStringListValue('WalListPhotosProjects',listDocumentsNoSend);
      }
    }catch(e){
      print('_onTapPhoto: ${e.toString()}');
    }
  }
}

Future<void> uploadUpdateUser() async {

  List<dynamic> listDocuments = await SharedPrefe().getValue('WalListUpdateAvatar') ?? [];
  print('MODIFICANDO ${listDocuments.length} documentos.');

  for(int x = 0; x < listDocuments.length; x++){

    //url path image |
    String data = listDocuments[x];

    try{
      var responseImage = await conexionHttp().httpSendImage(data);
      var valueImage = jsonDecode(responseImage.body);
      if(valueImage['status_code'] == 200){
        //ELIMINAR
        final file = File(data[0]);
        file.openRead();
        bool exist = await file.exists();
        if(exist){
          await File(data[0]).delete();
          print('SE ELIMINO AVATAR DE USUARIO');
        }
        //ELIMINAR TAREA DE LISTA
        List<String> listDocumentsNoSend = [];
        for(int x1 = 0; x1 < listDocuments.length; x1++){
          if(x != x1){ listDocumentsNoSend.add(listDocuments[x]); }
        }
        await SharedPrefe().setStringListValue('WalListUpdateAvatar',listDocumentsNoSend);
        print('USUARIO MODIFICADO');
      }
    }catch(e){
      print(e.toString());
      print('ERROR AL SUBIR ARCHIVO');
    }

    // try{
    //   var response = await conexionHttp().httpUpdateUser(jsonBody);
    //   var value = jsonDecode(response.body);
    //   if(value['status_code'] == 200){
    //     //ELIMINAR AUDIO
    //     final file = File(data[0]);
    //     file.openRead();
    //     bool exist = await file.exists();
    //     if(exist){
    //       await File(data[0]).delete();
    //       print('SE ELIMINO AVATAR DE USUARIO');
    //     }
    //     //ELIMINAR TAREA DE LISTA
    //     List<String> listDocumentsNoSend = [];
    //     for(int x1 = 0; x1 < listDocuments.length; x1++){
    //       if(x != x1){ listDocumentsNoSend.add(listDocuments[x]); }
    //     }
    //     await SharedPrefe().setStringListValue('WalListUpdateAvatar',listDocumentsNoSend);
    //     print('USUARIO MODIFICADO');
    //   }else{
    //     print('NO MODIFICADO');
    //   }
    // }catch(e){
    //   print(e.toString());
    //   print('ERROR MODIFICANDO');
    // }
  }
}
