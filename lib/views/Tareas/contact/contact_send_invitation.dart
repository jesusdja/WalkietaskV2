import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkietaskv2/App.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Login/LoginHome.dart';

class SendInvitation extends StatefulWidget {
  SendInvitation({this.myUserRes, this.mapIdUsersRes});
  final Usuario myUserRes;
  final Map<int,Usuario> mapIdUsersRes;
  @override
  _SendInvitationState createState() => _SendInvitationState();
}

class _SendInvitationState extends State<SendInvitation> {

  Usuario myUser;
  Map<int,Usuario> mapIdUsers;
  double alto = 0;
  double ancho = 0;
  TextStyle _textStyleTitle = TextStyle();
  TextStyle _textStyleSubTitle = TextStyle();
  TextStyle _textStyleDescription = TextStyle();
  TextStyle _textStylehiden = TextStyle();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUser = widget.myUserRes;
    mapIdUsers = widget.mapIdUsersRes;
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    _textStyleTitle = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.03,color: WalkieTaskColors.primary);
    _textStyleSubTitle = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.025, color: WalkieTaskColors.color_4D4D4D);
    _textStyleDescription = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.021, color: WalkieTaskColors.color_ACACAC, fontWeight: FontWeight.bold,spacing: 1.5);
    _textStylehiden = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.026, color: WalkieTaskColors.color_4D4D4D, fontWeight: FontWeight.bold,spacing: 1.3);

    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      appBar: AppBar(
        title: Container(
          width: ancho,
          child: Text('Contactos',
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
      body: _contenido(),
    );
  }

  Widget _contenido() {
    return Container(
      margin: EdgeInsets.all(alto * 0.04),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: ancho,
              child: Text('Invitación a usuarios', textAlign: TextAlign.center, style: _textStyleTitle,),
            ),
            SizedBox(height: alto * 0.02,),
            Container(
              width: ancho,
              child: Text('Contacto de Walkietask', textAlign: TextAlign.left, style: _textStyleSubTitle,),
            ),
            SizedBox(height: alto * 0.01,),
            Container(
              width: ancho,
              child: Text('Para invitar a quien ya tiene cuenta en Walkietask', textAlign: TextAlign.left, style: _textStyleDescription,),
            ),
            SizedBox(height: alto * 0.04,),
            Container(
              width: ancho,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: ancho * 0.02),
                      child: Text('Usuario o correo:', textAlign: TextAlign.right,style: _textStylehiden,),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: TextFildGeneric(
                        labelStyle: _textStylehiden,
                        onChanged: (text) {},
                        sizeH: alto,
                        sizeW: ancho,
                        borderColor: WalkieTaskColors.color_BABABA,
                        sizeHeight: alto * 0.041,
                        textAlign: TextAlign.left,
                        sizeBorder: 1.2,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: alto * 0.01,),
            Container(
              width: ancho,
              child: Align(
                alignment: Alignment.centerRight,
                child: RoundedButton(
                  backgroundColor: WalkieTaskColors.primary,
                  title: 'Invitar',
                  onPressed: () {},
                  radius: 5.0,
                  textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 1.2),
                  width: ancho * 0.2,
                  height: alto * 0.035,
                ),
              ),
            ),


            //***************************************************
            //***************************************************
            //***************************************************
            //***************************************************

            SizedBox(height: alto * 0.1,),
            Container(
              width: ancho,
              child: Text('Invitación a Walkietask', textAlign: TextAlign.center, style: _textStyleTitle,),
            ),
            SizedBox(height: alto * 0.02,),
            Container(
              width: ancho,
              child: Text('Invitar contacto nuevo a Walkietask', textAlign: TextAlign.left, style: _textStyleSubTitle,),
            ),
            SizedBox(height: alto * 0.01,),
            Container(
              width: ancho,
              child: Text('Para invitar a quien todavía no tenga cuenta en Walkietask', textAlign: TextAlign.left, style: _textStyleDescription,),
            ),
            SizedBox(height: alto * 0.04,),
            Container(
              width: ancho,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: ancho * 0.02),
                    child: Text('Correo:', textAlign: TextAlign.right,style: _textStylehiden,),
                  ),
                  Expanded(
                    child: Container(
                      child: TextFildGeneric(
                        labelStyle: _textStylehiden,
                        onChanged: (text) {},
                        sizeH: alto,
                        sizeW: ancho,
                        borderColor: WalkieTaskColors.color_BABABA,
                        sizeHeight: alto * 0.041,
                        textAlign: TextAlign.left,
                        sizeBorder: 1.2,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: alto * 0.02,),
            Container(
              width: ancho,
              child: Text('Mensaje (opcional)', textAlign: TextAlign.left,style: _textStylehiden,),
            ),
            SizedBox(height: alto * 0.01,),
            Container(
              child: TextFildGeneric(
                labelStyle: _textStylehiden,
                maxLines: 5,
                onChanged: (text) {},
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_BABABA,
                sizeHeight: alto * 0.1,
                textAlign: TextAlign.left,
                sizeBorder: 1.2,
              ),
            ),
            SizedBox(height: alto * 0.01,),
            Container(
              width: ancho,
              child: Align(
                alignment: Alignment.centerRight,
                child: RoundedButton(
                  backgroundColor: WalkieTaskColors.primary,
                  title: 'Invitar',
                  onPressed: () {},
                  radius: 5.0,
                  textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 1.2),
                  width: ancho * 0.2,
                  height: alto * 0.035,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
