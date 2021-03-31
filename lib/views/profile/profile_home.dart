import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/provider/home_provider.dart';
import 'package:walkietaskv2/services/provider/language_provider.dart';
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
  int selectIndex = 0;
  int selectIndexLang = 0;

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
      6 : false, //select barra recordatorio
      7 : false, //select idioma
    };

    initData();
    initPosPesonal();
  }

  Future<void> initData() async {
    avatarUser = await getPhotoUser();
    avatarUser = avatarUser ?? Image.network(avatarImage);
    if(myUser != null){
      if(myUser != null && myUser.avatar_100 != ''){
        avatarUser = Image.network(myUser.avatar_100);
      }
    }
    setState(() {});
  }

  initPosPesonal() async{
    selectIndex = await SharedPrefe().getValue('posPersonal') ?? 0;
    String lg = await SharedPrefe().getValue('language_code') ?? 'es';
    if(lg != 'es'){
      selectIndexLang = 1;
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
        child: Container(child: Cargando(translate(context: context, text: 'SavingUserData'),context),),
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
            child: Text(translate(context: context, text: 'myAccount'),
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
                res = await alertDeleteElement(context, translate(context: context, text: 'discardChanges'), button1: translate(context: context,text: 'discard'),);
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
              _textTitle(translate(context: context, text: 'profilePicture:')),
              SizedBox(height: alto * 0.03,),
              _profilePhoto(),
              SizedBox(height: alto * 0.06,),
              _textTitle('${translate(context: context, text: 'yourInformation')}:'),
              SizedBox(height: alto * 0.03,),
              _dataUser(),
              SizedBox(height: alto * 0.05,),
              _textTitle('${translate(context: context, text: 'modifyPassword:')}:'),
              SizedBox(height: alto * 0.02,),
              _dataUserPassword(),
              Container(
                width: ancho,
                padding: EdgeInsets.symmetric(horizontal: ancho * 0.06),
                child: Text('${translate(context: context, text: 'includeLowerAndUpper')}.', style: WalkieTaskStyles().stylePrimary(size: alto * 0.015),textAlign: TextAlign.right,),
              ),
              SizedBox(height: alto * 0.05,),
              _textTitle('${translate(context: context, text: 'receiveNotifications:')}:'),
              SizedBox(height: alto * 0.02,),
              columnSwitchRN(),
              SizedBox(height: alto * 0.04,),
              _textTitle('${translate(context: context, text: 'remindersButtonPlacement')}:'),
              SizedBox(height: alto * 0.02,),
              _selectRemenber(),
              SizedBox(height: alto * 0.04,),
              _textTitle('${translate(context: context, text: 'selectLanguage')}:'),
              SizedBox(height: alto * 0.02,),
              _selectLanguage(),
              SizedBox(height: alto * 0.1,),
              //_textTitle('Posición de botón de recordatorio:'),
              //SizedBox(height: alto * 0.1,),
              RoundedButton(
                borderColor: edit ? WalkieTaskColors.primary : WalkieTaskColors.color_969696,
                width: ancho * 0.3,
                height: alto * 0.05,
                radius: 5.0,
                title: translate(context: context, text: 'save'),
                textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.04, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1.5),
                backgroundColor: edit ? WalkieTaskColors.primary : WalkieTaskColors.color_B7B7B7,
                onPressed: () async {
                  if(edit){
                    await saveUser(context);
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
          _rowDataUser(controller:  controllerName, title: '${translate(context: context,text: 'name')}:', pos: 0),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controller: controllerLastName, title: '${translate(context: context,text: 'lastName')}:', pos: 1),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controller: controllerEmail, title: '${translate(context: context,text: 'email')}:', pos: 2),
        ],
      ),
    );
  }

  Widget _dataUserPassword(){
    return Container(
      width: ancho,
      child: Column(
        children: [
          _rowDataUser(controller: controllerPass, title: '${translate(context: context,text: 'oldPassword:')}:', obscure: true, pos: 3),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controller: controllerPass2, title: '${translate(context: context,text: 'newPassword:')}:', obscure: true, pos: 4),
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

  Widget columnSwitchRN(){
    return Container(
      width: ancho,
      margin: EdgeInsets.symmetric(horizontal: ancho * 0.1),
      child: Column(
        children: [
          receivedNotification('${translate(context: context,text: 'newTasks')}'),
          receivedNotification('${translate(context: context,text: 'invitationToProjects')}'),
          receivedNotification('${translate(context: context,text: 'dailyReminders')}'),
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
                showAlert('${translate(context: context,text: 'functionBlocked')}.',WalkieTaskColors.color_E07676);
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
            child: Text('${translate(context: context,text: 'change')}', style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.black, spacing: 0.5),),
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

  Widget _selectRemenber(){
    return Container(
      width: ancho,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          containerRemenber(1),
          containerRemenber(0),
          containerRemenber(2),
        ],
      ),
    );
  }

  Widget containerRemenber(int index){
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: alto * 0.02),
            child: Container(
              height: alto * 0.2,
              width: ancho * 0.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ViewImage().assetsImage("assets/image/reminder$index.png").image,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Radio(
            value: index,
            groupValue: selectIndex,
            activeColor: WalkieTaskColors.primary,
            onChanged: (newIndex) async {
              setState(() {
                selectIndex = newIndex;
                mapData[6] = true;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _selectLanguage(){
    return Container(
      width: ancho,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          containerLanguage(0),
          containerLanguage(1),
        ],
      ),
    );
  }

  Widget containerLanguage(int index){

    String language = 'Español';
    if(index == 1){
      language = 'Ingles';
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: ancho * 0.25,
            child: Text(language, style: WalkieTaskStyles().stylePrimary(color: WalkieTaskColors.color_969696, size: alto * 0.025, fontWeight: FontWeight.bold, spacing: 0.5),),
          ),
          Radio(
            value: index,
            groupValue: selectIndexLang,
            activeColor: WalkieTaskColors.primary,
            onChanged: (newIndex) async {
              setState(() {
                selectIndexLang = newIndex;
                mapData[7] = true;
              });
            },
          )
        ],
      ),
    );
  }

  Future<void> saveUser(BuildContext context) async {
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
        showAlert('${translate(context: context,text: 'nameNpEmpty')}',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if(mapData[1]){
      if(controllerLastName.text.isNotEmpty){
        body['surname'] = controllerLastName.text;
      }else{
        showAlert('${translate(context: context,text: 'lastNameNoEmpty')}',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if(mapData[2]){
      if(controllerEmail.text.isNotEmpty){
        if(validateEmailAddress(controllerEmail.text,context)['valid']){
          body['email'] = controllerEmail.text;
        }else{
          showAlert(validateEmailAddress(controllerEmail.text,context)['sms'],WalkieTaskColors.color_E07676);
          notError = false;
        }
      }else{
        showAlert('${translate(context: context,text: 'EmailNoEmpty')}',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if(mapData[3] && !mapData[4]){
      showAlert('${translate(context: context,text: 'mustNewPassword')}',WalkieTaskColors.color_E07676);
      notError = false;
    }

    if(!mapData[3] && mapData[4]){
      showAlert('${translate(context: context,text: 'mustOldPassword')}',WalkieTaskColors.color_E07676);
      notError = false;
    }

    if(mapData[3] && mapData[4]){
      if(controllerPass.text.isNotEmpty){
        if(controllerPass2.text.isNotEmpty){
          if(validatePassword(controllerPass2.text,context)['valid']){
            body['old_password'] = controllerPass.text;
            body['password'] = controllerPass2.text;
          }else{
            showAlert(validatePassword(controllerPass2.text,context)['sms'],WalkieTaskColors.color_E07676);
            notError = false;
          }
        }else{
          showAlert('${translate(context: context,text: 'newPasswordNoEmpty')}',WalkieTaskColors.color_E07676);
          notError = false;
        }
      }else{
        showAlert('${translate(context: context,text: 'oldPasswordNoEmpty')}',WalkieTaskColors.color_E07676);
        notError = false;
      }
    }

    if( mapData[6]){
      final posPersonalProvider = Provider.of<HomeProvider>(context, listen: false);
      try{
        posPersonalProvider.posPersonal = selectIndex;
        if(body.length <= 1){
          notError = false;
        }
      }catch(_){}
    }

    if( mapData[7]){
      var appLanguage = Provider.of<LanguageProvider>(context,listen: false);
      try{
        appLanguage.changeLanguage( selectIndexLang == 0 ? Locale("es") : Locale("en"));
        if(body.length <= 1){
          notError = false;
        }
      }catch(_){}
    }

    if((body.length > 1 || validateEmailAddress(controllerEmail.text,context)['valid']) && notError){
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
          showAlert('${translate(context: context,text: 'userUpdatedSuccessfully')}',WalkieTaskColors.color_89BD7D);
        }else{

          String error = '${translate(context: context,text: 'errorSendingInformation')}';
          if(value['message'] != null){
            error = value['message'];
          }
          showAlert(error,WalkieTaskColors.color_E07676);
        }
      }catch(e){
        print(e.toString());
        showAlert('${translate(context: context,text: 'errorSendingInformation')}',WalkieTaskColors.color_E07676);
      }
    }else{
      if(mapData[6] || mapData[7]){
        Map result = {0 : true, 1: false};
        result[1] = true;
        Navigator.of(context).pop(result);
        showAlert('${translate(context: context,text: 'userUpdatedSuccessfully')}',WalkieTaskColors.color_89BD7D);
      }
    }

    setState(() {
      loadSave = false;
    });
  }

}
