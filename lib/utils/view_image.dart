import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';

class ViewImage {
  Image assetsImage(String ruta,{Color color: WalkieTaskColors.white}) {
    return Image.asset(ruta, color: color,); //AssetImage("assets/image/$image.png");
  }

  Image netWork(String ruta) {
    Image image = Image.network(ruta);
    return image;
  }
}
