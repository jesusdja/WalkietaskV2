import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/upload_background_documents.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/gallery_camera_dialog.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/utils/view_image.dart';

class ProfilePhoto extends StatefulWidget {

  ProfilePhoto({@required this.myUser});
  final Usuario myUser;

  @override
  _ProfilePhotoState createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {

  Usuario myUser;
  Image avatarUser;
  double alto = 0;
  double ancho = 0;

  @override
  void initState() {
    super.initState();
    myUser = widget.myUser;
    initData();
  }

  Future<void> initData() async {
    avatarUser = await getPhotoUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    avatarUser = avatarUser ?? Image.network(avatarImage);
    if(myUser != null){
      if(myUser != null && myUser.avatar != ''){
        avatarUser = Image.network(myUser.avatar);
      }
    }

    return Container(
      width: ancho,
      child: Column(
        children: [
          InkWell(
            onTap: () => _onTapPhoto(),
            child: Container(
              child: Container(
                padding: const EdgeInsets.all(2.0), // borde width
                decoration: new BoxDecoration(
                  color: WalkieTaskColors.color_969696, // border color
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: alto * 0.1,
                  backgroundImage: avatarUser.image,
                ),
              ),
            ),
          ),
          SizedBox(height: alto * 0.01,),
          InkWell(
            onTap: () => _onTapPhoto(),
            child: Text('Cambiar', style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.black, spacing: 0.5),),
          ),
        ],
      ),
    );
  }

  void _onTapPhoto(){
    final callback = Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => GalleryCameraDialog(
          isVideo: false,
        ))
    );
    callback.then(
          (media) async {
        if(media != null) {
          PickedFile _imageFile = media as PickedFile;
          File croppedImage = await ViewImage().croppedImageView(_imageFile.path, cropStyle: CropStyle.circle);
          if(croppedImage != null){
            avatarUser = Image.file(croppedImage);
            setState(() {});
            await SharedPrefe().setStringValue('WalkiephotoUser', croppedImage.path);

            List<dynamic> listDocuments = await SharedPrefe().getValue('WalListUpdateAvatar') ?? [];
            List<String> listNew = [];
            listDocuments.forEach((element) { listNew.add(element);});
            listNew.add(croppedImage.path);
            await SharedPrefe().setStringListValue('WalListUpdateAvatar', listNew);
            uploadUpdateUser();
          }
        }
      },
    );
  }
}
