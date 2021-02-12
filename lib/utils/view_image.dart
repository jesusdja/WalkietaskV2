import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ViewImage {
  Image assetsImage(String ruta,{Color color: WalkieTaskColors.white}) {
    return Image.asset(ruta, color: color,); //AssetImage("assets/image/$image.png");
  }

  Image netWork(String ruta) {
    Image image = Image.network(ruta);
    return image;
  }

  Future<File> croppedImageView(String _imageFilepath,{CropStyle cropStyle:CropStyle.rectangle}) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: _imageFilepath,
      cropStyle: cropStyle,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxHeight: 800,
      maxWidth: 800,
      compressFormat: ImageCompressFormat.png,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Editar imagen',
        toolbarColor: Colors.white,
        toolbarWidgetColor: Colors.black,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'Editar imagen',
      ),
    );
    return croppedImage;
  }
}
