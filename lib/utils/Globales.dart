import 'dart:io';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/main.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

//String avatarImage = 'http://www.nabu.me.php72-7.phx1-1.websitetestlink.com/uploads/system/avatar.png';
Widget avatarWidget({@required double alto, @required String text, double radius = 0.03}){
  return CircleAvatar(
    backgroundColor: WalkieTaskColors.color_76ADE3,
    radius: alto * radius,
    child: Padding(
      padding: EdgeInsets.all(alto * 0.003),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: alto * radius,
        child: Center(child: Text(text ?? '', style: WalkieTaskStyles().stylePrimary(color: WalkieTaskColors.color_76ADE3,size: alto * (radius - 0.007), fontWeight: FontWeight.bold),)),
      ),
    ),
  );
}
Widget avatarWidgetProject({@required double alto, @required String text, double radius = 0.03}){
  return CircleAvatar(
    backgroundColor: WalkieTaskColors.color_8CD59B,
    radius: alto * radius,
    child: Padding(
      padding: EdgeInsets.all(alto * 0.003),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: alto * radius,
        child: Center(child: Text(text ?? '', style: WalkieTaskStyles().stylePrimary(color: WalkieTaskColors.color_8CD59B,size: alto * (radius - 0.007), fontWeight: FontWeight.bold),)),
      ),
    ),
  );
}
Widget avatarWidgetImage({@required double alto, @required String pathImage, double radius = 0.03}){
  return Container(
    child: CircleAvatar(
      radius: alto * radius,
      backgroundImage: Image.network(pathImage).image,
    ),
  );
}

Future<String> obtenerToken() async {

  String token  = await SharedPrefe().getValue('unityToken');
  return token;
}

String translate({@required BuildContext context, @required String text}){
  return AppLocalizations.of(context).translate(text);
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






