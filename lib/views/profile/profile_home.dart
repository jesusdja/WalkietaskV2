import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/value_validators.dart';
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
    controllerEmail.text = myUser.email;

    mapData = {
      0 : false, //nombre
      1 : false, //apellido
      2 : false, //correo
      3 : false, //clave anterios
      4 : false, //clave nueva
    };
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
              if(edit){
                bool res = false;
                res = await alertDeleteElement(context, '¿Descartar cambios realizados?', button1: 'Descartar',);
                if(res != null && res){
                  Navigator.of(context).pop();
                }
              }else{
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            edit ? Container(
              margin: EdgeInsets.only(right: ancho * 0.05),
              child: InkWell(
                onTap: () => saveUser(),
                child: Icon(Icons.save_outlined, color: WalkieTaskColors.color_969696, size: alto * 0.035,),
              ),
            ) : Container(),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: alto * 0.035,),
              _textTitle('Foto de perdil:'),
              SizedBox(height: alto * 0.03,),
              ProfilePhoto(myUser: myUser,),
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
              SizedBox(height: alto * 0.1,),

              SizedBox(height: alto * 0.1,),
              _textTitle('Posición de botón de recordatorio:'),
              SizedBox(height: alto * 0.1,),

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
            child: Text(title, style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022, spacing: 0.5),textAlign: TextAlign.right,),
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

    Map<String,dynamic> body = {
      'email' : myUser.email,
    };
    if(mapData[0]){
      if(controllerName.text.isNotEmpty){
        body['name'] = controllerName.text;
      }else{
        showAlert('El nombre no puede estar vacio',WalkieTaskColors.color_E07676);
      }
    }

    if(mapData[1]){
      if(controllerLastName.text.isNotEmpty){
        body['name'] = controllerLastName.text;
      }else{
        showAlert('El apellido no puede estar vacio',WalkieTaskColors.color_E07676);
      }
    }

    if(mapData[2]){
      if(controllerEmail.text.isNotEmpty){
        if(validateEmailAddress(controllerEmail.text)['valid']){
          body['email'] = controllerEmail.text;
        }else{
          showAlert(validateEmailAddress(controllerEmail.text)['sms'],WalkieTaskColors.color_E07676);
        }
      }else{
        showAlert('El correo no puede estar vacio',WalkieTaskColors.color_E07676);
      }
    }

    if(mapData[3] && !mapData[4]){
      showAlert('Debe agregar una nueva clave',WalkieTaskColors.color_E07676);
    }

    if(!mapData[3] && mapData[4]){
      showAlert('Debe agregar clave anterior',WalkieTaskColors.color_E07676);
    }

    if(mapData[3] && mapData[4]){
      if(controllerPass.text.isNotEmpty){
        if(controllerPass2.text.isNotEmpty){
          body['old_password'] = controllerPass.text;
          body['password'] = controllerPass2.text;
        }else{
          showAlert('Nueva clave no puede estar vacio',WalkieTaskColors.color_E07676);
        }
      }else{
        showAlert('Clave anterior no puede estar vacio',WalkieTaskColors.color_E07676);
      }
    }

    if(body.length > 1 || validateEmailAddress(controllerEmail.text)['valid']){
      try{
        var response = await conexionHttp().httpUpdateUser(body);
        var value = jsonDecode(response.body);
        if(response.statusCode == 200){

        }else{
          showAlert('Error al enviar los datos.',WalkieTaskColors.color_E07676);
        }
      }catch(e){
        print(e.toString());
      }
    }

    setState(() {
      loadSave = false;
    });
  }

}
