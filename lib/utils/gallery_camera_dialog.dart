import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:walkietaskv2/utils/Colores.dart';

class GalleryCameraDialog extends StatelessWidget {
  const GalleryCameraDialog({
    Key key,
    @required this.isVideo,
  }) : super(key: key);

  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: WalkieTaskColors.primary,
        body: GestureDetector(
          onTap: () {},
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: WalkieTaskColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          OptionWidget.camera(
                            () => _selectResource(
                              ImageSource.camera,
                              context
                            ),
                          ),
                          OptionWidget.gallery(
                            () => _selectResource(
                              ImageSource.gallery,
                                context
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectResource(ImageSource source, BuildContext context) async {
    Future<File> pickSource;
    Future<PickedFile> pickSource2;
    if (isVideo) {
      pickSource = ImagePicker.pickVideo(source: source);
    } else {
      pickSource2 = ImagePicker().getImage(source: source,maxWidth: 800,maxHeight: 800);
    }
    try {
      PickedFile selectedFile = await pickSource2;
      if (selectedFile == null) return; //No se eligió una imagen
      Navigator.of(context).pop(selectedFile);
    } catch (e) {
      print("Error = $e");
    }
  }
}

class OptionWidget extends StatelessWidget {
  const OptionWidget._({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  factory OptionWidget.camera(VoidCallback onTap) {
    return OptionWidget._(
      icon: Icons.camera,
      title: "Cámara",
      onTap: onTap,
    );
  }

  factory OptionWidget.gallery(VoidCallback onTap) {
    return OptionWidget._(
      icon: Icons.filter,
      title: "Galería",
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Icon(icon,size: 42,),
            Text(
              title,
            )
          ],
        ),
      ),
    );
  }
}
