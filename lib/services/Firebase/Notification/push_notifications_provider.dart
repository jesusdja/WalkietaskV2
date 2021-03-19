import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class PushProvider{

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final _mensajesStreamController = StreamController<Map<String,String>>.broadcast();
  Stream<Map<String,String>> get mensajes => _mensajesStreamController.stream;

  dispose(){
    _mensajesStreamController?.close();
  }

  getToken() async {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) async {
      await SharedPrefe().setStringValue('walkietaskIdNoti',token);
      print('======== TOKEN FIREBASE ========');
      print('======== TOKEN FIREBASE ========');
      print(token);
      print('======== TOKEN FIREBASE ========');
      print('======== TOKEN FIREBASE ========');
      try{
        Usuario myUser = await UpdateData().getMyUser();
        if(myUser.fcmToken == null || myUser.fcmToken != token){
          await conexionHttp().httpUpdateTokenFirebase(token);
        }
      }catch(e){
        print('ERROR AL OBTENER USUARIO EN TOKEN');
      }
    });
  }


  initNotificaciones() async {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      //APP ABIERTA
      // ignore: missing_return
      onMessage: (info){
        //ABIERTA
        print('============= onMessage ========== ');
        print(info);
        Map<String,String> argumento = Map();
        argumento['type'] = '1';
        if(Platform.isAndroid){
          argumento['idDoc'] = info['data']['idDoc'];
          argumento['table'] = info['data']['table'];// contacts - tasks
          argumento['description'] = info['data']['description'];
        }else{
          argumento['idDoc'] = info['idDoc'];
          argumento['table'] = info['table'];
          argumento['description'] = info['description'];
        }
        _mensajesStreamController.sink.add(argumento);
      },
      // ignore: missing_return
      onResume: (info){
        //MINIMIZADA
        print('============= onResume ========== ');
        print(info);
        Map<String,String> argumento = Map();
        argumento['type'] = '2';
        if(Platform.isAndroid){
          argumento['idDoc'] = info['data']['idDoc'];
          argumento['table'] = info['data']['table'];// contacts - tasks
          argumento['description'] = info['data']['description'];
        }else{
          argumento['idDoc'] = info['idDoc'];
          argumento['table'] = info['table'];
          argumento['description'] = info['description'];
        }
        _mensajesStreamController.sink.add(argumento);
      },
      // ignore: missing_return
      onLaunch: (info){
        //SEGUNDO PLANO
        print('============= onLaunch ========== ');
        print(info);
        Map<String,String> argumento = Map();
        argumento['type'] = '3';
        if(Platform.isAndroid){
          argumento['idDoc'] = info['data']['idDoc'];
          argumento['table'] = info['data']['table'];// contacts - tasks
          argumento['description'] = info['data']['description'];
        }else{
          argumento['idDoc'] = info['idDoc'];
          argumento['table'] = info['table'];
          argumento['description'] = info['description'];
        }
        _mensajesStreamController.sink.add(argumento);
      },
    );
  }


}