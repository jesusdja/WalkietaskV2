import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pushProvider{

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final _mensajesStreamController = StreamController<Map<String,String>>.broadcast();
  Stream<Map<String,String>> get mensajes => _mensajesStreamController.stream;

  dispose(){
    _mensajesStreamController?.close();
  }

  obtenerToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) async {
      await prefs.setString('walkietaskIdNoti',token);
      print('======== TOKEN ========');
      print(token);
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
        // if(Platform.isAndroid){
        //   argumento['grupo'] = info['data']['grupo'];
        //   argumento['nuevo'] = info['data']['nuevo'];
        //   argumento['to'] = 'onMessage';
        // }else{
        //   argumento['grupo'] = info['grupo'];
        //   argumento['nuevo'] = info['nuevo'];
        //   argumento['to'] = 'onMessage';
        // }
        _mensajesStreamController.sink.add(argumento);
      },
      // ignore: missing_return
      onResume: (info){
        //MINIMIZADA
        print('============= onResume ========== ');
        print(info);
        Map<String,String> argumento = Map();
        // if(Platform.isAndroid){
        //   argumento['grupo'] = info['data']['grupo'];
        //   argumento['nuevo'] = info['data']['nuevo'];
        //   argumento['to'] = 'onResume';
        // }else{
        //   argumento['grupo'] = info['grupo'];
        //   argumento['nuevo'] = info['nuevo'];
        //   argumento['to'] = 'onResume';
        // }
        _mensajesStreamController.sink.add(argumento);
      },
      // ignore: missing_return
      onLaunch: (info){
        //SEGUNDO PLANO
        print('============= onLaunch ========== ');
        print(info);
        Map<String,String> argumento = Map();
        // if(Platform.isAndroid){
        //   argumento['grupo'] = info['data']['grupo'];
        //   argumento['nuevo'] = info['data']['nuevo'];
        //   argumento['to'] = 'onLaunch';
        // }else{
        //   argumento['grupo'] = info['grupo'];
        //   argumento['nuevo'] = info['nuevo'];
        //   argumento['to'] = 'onLaunch';
        // }
        _mensajesStreamController.sink.add(argumento);
      },
    );
  }


}