import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';

class pushProvider{

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final _mensajesStreamController = StreamController<Map<String,String>>.broadcast();
  Stream<Map<String,String>> get mensajes => _mensajesStreamController.stream;

  dispose(){
    _mensajesStreamController?.close();
  }

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) async {
      await prefs.setString('walkietaskIdNoti',token);
      print('======== TOKEN FIREBASE ========');
      print('======== TOKEN FIREBASE ========');
      print(token);
      print('======== TOKEN FIREBASE ========');
      print('======== TOKEN FIREBASE ========');
      try{
        Usuario myUser = await UpdateData().getMyUser();
        if(myUser.fcmToken == null || myUser.fcmToken != token){
          var response = await conexionHttp().httpUpdateTokenFirebase(token);
          var value = jsonDecode(response.body);
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
          argumento['table'] = info['data']['table']; // contacts - tasks
        }else{
          argumento['idDoc'] = info['idDoc'];
          argumento['table'] = info['table'];
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
          argumento['table'] = info['data']['table']; // contacts - tasks
        }else{
          argumento['idDoc'] = info['idDoc'];
          argumento['table'] = info['table'];
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
          argumento['table'] = info['data']['table']; // contacts - tasks
        }else{
          argumento['idDoc'] = info['idDoc'];
          argumento['table'] = info['table'];
        }
        _mensajesStreamController.sink.add(argumento);
      },
    );
  }


}