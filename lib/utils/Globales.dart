import 'dart:io';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

String avatarImage = 'http://www.nabu.me.php72-7.phx1-1.websitetestlink.com/uploads/system/avatar.png';

Future<String> obtenerToken() async {

  String token  = await SharedPrefe().getValue('unityToken');
  return token;
}

Future<bool> checkConectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return true;
    }
  } on SocketException catch (_) {
    print('not connected');
  }
  return false;
}

Future<void> addPopTask(int num) async {
  try{
    int pop = await SharedPrefe().getValue('popValueTask') ?? 0;
    pop = pop + num;
    await SharedPrefe().setIntValue('popValueTask', pop);
  }catch(e){
    print(e.toString());
  }
}

Future<Image> getPhotoUser() async {
  String pathPhoto = await SharedPrefe().getValue('WalkiephotoUser') ?? '';
  Image photo;
  if(pathPhoto != null && pathPhoto.isNotEmpty){
    photo = Image.file(File(pathPhoto));
  }
  return photo;
}






