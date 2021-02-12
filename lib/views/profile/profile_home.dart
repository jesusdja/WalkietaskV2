import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
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

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  TextEditingController controllerPass2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    myUser = widget.myUser;
    controllerName.text = myUser.name;
    controllerEmail.text = myUser.email;
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return Scaffold(
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
          _rowDataUser(controllerName, 'Nombre:'),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controllerEmail, 'Correo:'),
        ],
      ),
    );
  }

  Widget _dataUserPassword(){
    return Container(
      width: ancho,
      child: Column(
        children: [
          _rowDataUser(controllerName, 'Clave anterior:'),
          SizedBox(height: alto * 0.02,),
          _rowDataUser(controllerEmail, 'Nueva clave:'),
        ],
      ),
    );
  }

  Widget _rowDataUser(TextEditingController controller, String title){
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
              ),
            ),
          )
        ],
      ),
    );
  }


}
