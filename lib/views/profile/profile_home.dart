import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/upload_background_documents.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/gallery_camera_dialog.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/switch_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/value_validators.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/profile/profile_photo.dart';

class ProfileHome extends StatefulWidget {

  ProfileHome({@required this.myUser});

  final Usuario myUser;

  @override
  _ProfileHomeState createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {

  Usuario myUser;
  double alto = 0;
  double ancho = 0;
  bool loadSave = false;
  Map<int,bool> mapData = {};
  Image avatarUser;
  String urlImage = '';

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerLastName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextEditingController controllerPass2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    myUser = widget.myUser;
    controllerName.text = myUser.name;
    controllerLastName.text = myUser.surname;
    controllerEmail.text = myUser.email;

    mapData = {
      0 : false, //nombre
      1 : false, //apellido
      2 : false, //correo
      3 : false, //clave anterios
      4 : false, //clave nueva
      5 : false, //Imagen
    };

    initData();
  }

  Future<void> initData() async {
    avatarUser = await getPhotoUser();
    avatarUser = avatarUser ?? Image.network(avatarImage);
    if(myUser != null){
      if(myUser != null && myUser.avatar != ''){
        avatarUser = Image.network(myUser.avatar);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    bool edit = false;
    mapData.forEach((key, value) { if(value){ edit = true;} });

    return loadSave ?
    Scaffold(
      body: Center(
        child: Container(child: Cargando('Guardando datos de usuario',context),),
      ),
    )
        :
    GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            width: ancho,
            child: Text('Mi Cuenta',
              style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696),textAlign: TextAlign.right,),
          ),
          elevation: 0,
          backgroundColor: Colors.grey[100],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.grey,size: alto * 0.04,),
            onPressed: () async {

              Map result = { 0: false, 1:false };

              if(edit){
                bool res = false;
                res = await alertDeleteElement(context, '¿Descartar cambios realizados?', button1: 'Descartar',);
                if(res != null && res){
                  Navigator.of(context).pop( result );
                }
              }else{
                Navigator.of(context).pop( result );
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: alto * 0.035,),
              _textTitle('Foto de perdil:'),
              SizedBox(height: alto * 0.03,),
              _profilePhoto(),
              SizedBox(height: alto * 0.06,),
              _textTitle('Tus datos:'),
              SizedBox(height: alto * 0.03,),
              _dataUser(),
              SizedBox(height: alto * 0.05,),
              _textTitle('Modificar clave de acceso:'),
              SizedBox(height: alto * 0.02,),
              _dataUserPassword(),
              Container(
                width: ancho,
                padding: EdgeInsets.symmetric(horizontal: ancho * 0.06),
                child: Text('Debe incluir minuscula, mayúscula y número.', style: WalkieTaskStyles().stylePrimary(size: alto * 0.015),textAlign: TextAlign.right,),
              ),
              SizedBox(height: alto * 0.05,),
              _textTitle('Recibir notificaciones:'),
              SizedBox(height: alto * 0.02,),
              columnSwitchRN(),
              SizedBox(height: alto * 0.1,),
              //_textTitle('Posición de botón de recordatorio:'),
              //SizedBox(height: alto * 0.1,),
              RoundedButton(
                borderColor: edit ? WalkieTaskColors.primary : WalkieTaskColors.color_969696,
                width: ancho * 0.3,
                height: alto * 0.05,
                radius: 5.0,
                title: 'Guardar',
                textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.04, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1.5),
                backgroundColor: edit ? WalkieTaskColors.primary : WalkieTaskColors.color_B7B7B7,
                onPressed: () async {
                  if(edit){
                    await saveUser();
                  }
                },
              ),
              SizedBox(height: alto * 0.1,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textTitle(String title){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(left: ancho * 0.05),
      child: Text(title, style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_969696, fontWeight: FontWeight.bold),),
    );
  }

  Widget _dataUser(){
    return Container(
      width: ancho,
      child: Column(
        children: [
          _rowDataUser(controller:  controllerName, title: 'Nombre:', pos: 0),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controller: controllerLastName, title: 'Apellido:', pos: 1),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controller: controllerEmail, title: 'Correo:', pos: 2),
        ],
      ),
    );
  }

  Widget _dataUserPassword(){
    return Container(
      width: ancho,
      child: Column(
        children: [
          _rowDataUser(controller: controllerPass, title: 'Clave anterior:', obscure: true, pos: 3),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controller: controllerPass2, title: 'Nueva clave:', obscure: true, pos: 4),
        ],
      ),
    );
  }

  Widget _rowDataUser({ @required TextEditingController controller, @required String title,  bool obscure = false, @required int pos} ){
    return Container(
      width: ancho,
      padding: EdgeInsets.symmetric(horizontal: ancho * 0.06),
      child: Row(
        children: [
          Container(
            width: ancho * 0.32,
            child: Text(title, style: WalkieTaskStyles().stylePrimary(size: alto * 0.022, spacing: 0.5),textAlign: TextAlign.right,),
          ),
          SizedBox(width: ancho * 0.02,),
          Expanded(
            child: Container(
              child: TextFildGeneric(
                obscure: obscure,
                labelStyle: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
                textInputType: TextInputType.emailAddress,
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_B7B7B7,
                sizeHeight: alto * 0.04,
                textAlign: TextAlign.left,
                textEditingController: controller,
                initialValue: null,
                sizeBorder: 1.2,
                textCapitalization: TextCapitalization.none,
                onChanged: ( value ){
                  setState(() {
                    mapData[pos] = true;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveUser() async {
    setState(() {
      loadSave = true;
    });
    bool notError = true;

    Map<String,dynamic> body = {
      'email' : myUser.email,
    };
    if(mapData[0]){
      if(controllerName.text.isNotEmpty){
        body['name'] = controllerName.text;
      }else{
        showAlert('El nombre no puede estar vacio',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if(mapData[1]){
      if(controllerLastName.text.isNotEmpty){
        body['surname'] = controllerLastName.text;
      }else{
        showAlert('El apellido no puede estar vacio',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if(mapData[2]){
      if(controllerEmail.text.isNotEmpty){
        if(validateEmailAddress(controllerEmail.text)['valid']){
          body['email'] = controllerEmail.text;
        }else{
          showAlert(validateEmailAddress(controllerEmail.text)['sms'],WalkieTaskColors.color_E07676);
          notError = false;
        }
      }else{
        showAlert('El correo no puede estar vacio',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if(mapData[3] && !mapData[4]){
      showAlert('Debe agregar una nueva clave',WalkieTaskColors.color_E07676);
      notError = false;
    }

    if(!mapData[3] && mapData[4]){
      showAlert('Debe agregar clave anterior',WalkieTaskColors.color_E07676);
      notError = false;
    }

    if(mapData[3] && mapData[4]){
      if(controllerPass.text.isNotEmpty){
        if(controllerPass2.text.isNotEmpty){
          if(validatePassword(controllerPass2.text)['valid']){
            body['old_password'] = controllerPass.text;
            body['password'] = controllerPass2.text;
          }else{
            showAlert(validatePassword(controllerPass2.text)['sms'],WalkieTaskColors.color_E07676);
            notError = false;
          }
        }else{
          showAlert('Nueva clave no puede estar vacio',WalkieTaskColors.color_E07676);
          notError = false;
        }
      }else{
        showAlert('Clave anterior no puede estar vacio',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if((body.length > 1 || validateEmailAddress(controllerEmail.text)['valid']) && notError){
      try{
        var response = await conexionHttp().httpUpdateUser(body);
        var value = jsonDecode(response.body);
        if(response.statusCode == 200){

          Map result = {0 : true, 1: false};

          if(mapData[5]){
            await SharedPrefe().setStringValue('WalkiephotoUser', urlImage);

            List<dynamic> listDocuments = await SharedPrefe().getValue('WalListUpdateAvatar') ?? [];
            List<String> listNew = [];
            listDocuments.forEach((element) { listNew.add(element);});
            listNew.add(urlImage);
            await SharedPrefe().setStringListValue('WalListUpdateAvatar', listNew);
            uploadUpdateUser();

            result[1] = true;
          }


          Navigator.of(context).pop(result);
          showAlert('Usuario editado con exito',WalkieTaskColors.color_89BD7D);
        }else{

          String error = 'Error al enviar los datos.';
          if(value['message'] != null){
            error = value['message'];
          }
          showAlert(error,WalkieTaskColors.color_E07676);
        }
      }catch(e){
        print(e.toString());
        showAlert('Error al enviar los datos.',WalkieTaskColors.color_E07676);
      }
    }

    setState(() {
      loadSave = false;
    });
  }

  Widget columnSwitchRN(){
    return Container(
      width: ancho,
      margin: EdgeInsets.symmetric(horizontal: ancho * 0.1),
      child: Column(
        children: [
          receivedNotification('Nuevas tareas'),
          receivedNotification('Invitación a proyectos'),
          receivedNotification('Recordatorios diarios'),
        ],
      ),
    );
  }

  Widget receivedNotification(String title){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(right: ancho * 0.03, top: alto * 0.01, bottom: alto * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(title, style: WalkieTaskStyles().stylePrimary(color: WalkieTaskColors.color_969696, size: alto * 0.02, fontWeight: FontWeight.bold, spacing: 0.5),),
          SizedBox(width: ancho * 0.02,),
          Container(
            margin: EdgeInsets.only(right: ancho * 0.02),
            child: CustomSwitchLocal(
              value: true,
              sizeH: alto * 0.025,
              sizeW: ancho * 0.11,
              onChanged: (bool val) async {
                showAlert('Por los momentos esta función se encuentra bloqueada.',WalkieTaskColors.color_E07676);
              },
              colorBgOff: WalkieTaskColors.color_DD7777,
              colorBgOn: WalkieTaskColors.color_89BD7D,
              sizeCircule: alto * 0.025,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePhoto(){
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
                child: avatarUser != null ? CircleAvatar(
                  radius: alto * 0.1,
                  backgroundImage: avatarUser.image,
                ) : CircleAvatar(
                  radius: alto * 0.1,
                  backgroundColor: WalkieTaskColors.color_B7B7B7,
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
    callback.then((media) async {
        if(media != null) {
          PickedFile _imageFile = media as PickedFile;
          File croppedImage = await ViewImage().croppedImageView(_imageFile.path, cropStyle: CropStyle.circle);
          if(croppedImage != null){
            avatarUser = Image.file(croppedImage);
            mapData[5] = true;
            urlImage = croppedImage.path;
            setState(() {});


            /*
            List<dynamic> listDocuments = await SharedPrefe().getValue('WalListUpdateAvatar') ?? [];
            List<String> listNew = [];
            listDocuments.forEach((element) { listNew.add(element);});
            listNew.add(croppedImage.path);
            await SharedPrefe().setStringListValue('WalListUpdateAvatar', listNew);
            uploadUpdateUser();
            */
          }
        }
      },
    );
  }

}
