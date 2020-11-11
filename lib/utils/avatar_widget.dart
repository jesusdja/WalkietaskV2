import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/view_image.dart';

Widget avatarCircule(Color borde, String rutaImage,double radiu){
  return Container(
      child: CircleAvatar(
        radius: radiu,
        backgroundColor: WalkieTaskColors.white,
        backgroundImage: ViewImage()
            .assetsImage('assets/image/$rutaImage')
            .image,
      ),
      padding: const EdgeInsets.all(2.0), // borde width
      decoration: new BoxDecoration(
        color: borde, // border color
        shape: BoxShape.circle,
      ));
}

Widget avatarCirculeNet(Color borde, String rutaImage,double radiu){
  Widget res = Container();
  try{
    res = Container(
        child: CircleAvatar(
          radius: radiu,
          backgroundImage: ViewImage()
              .netWork(rutaImage)
              .image,
        ),
        padding: const EdgeInsets.all(2.0), // borde width
        decoration: new BoxDecoration(
          color: borde, // border color
          shape: BoxShape.circle,
        ));
  }catch(e){
    print(e.toString());
  }


  return res;
}

Widget avatarCirculeImage(Color borde, Image imagen,double radiu){
  return Container(
      child: CircleAvatar(
        radius: radiu,
        backgroundImage: imagen.image,
        backgroundColor: WalkieTaskColors.white,
      ),
      padding: const EdgeInsets.all(2.0), // borde width
      decoration: new BoxDecoration(
        color: borde, // border color
        shape: BoxShape.circle,
      ));
}