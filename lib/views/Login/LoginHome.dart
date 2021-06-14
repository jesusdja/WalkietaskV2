import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Permisos.dart';
import 'package:walkietaskv2/services/auth.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/utils/finish_app.dart';
import 'package:walkietaskv2/views/Login/widgets/recover_password.dart';
import 'package:walkietaskv2/views/Register/register_page.dart';

class LoginHome extends StatefulWidget {
  @override
  _LoginHomeState createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {

  double alto = 0;
  double ancho = 0;
  String nombre = '';
  String pasw = '';
  bool cargando = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController _email = new TextEditingController();
  TextEditingController _pass = new TextEditingController();

  bool seePass = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<bool> exit() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
          child: cargando ? Cargando(translate(context: context,text: 'VerifyingInformation'),context) :
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: alto * 0.15,),
                _logo(),
                SizedBox(height: alto * 0.15,),
                _form(),
                SizedBox(height: alto * 0.15,),
                _viewRegistre(context),
              ],
            ),
          ),
          onWillPop: exit
        ),
      ),
    );
  }

  Widget _viewRegistre(BuildContext contextLogin) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            translate(context: context, text: 'haveAnAccount'),
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02,spacing: 0.5),
          ),
          InkWell(
            child: Text(translate(context: context, text: 'SignInHereFree'),
              style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02,spacing: 0.5),
            ),
            onTap: () {
              Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context2) => new RegisterPage(contextLogin: contextLogin,)));
            },
          ),
        ],
      ),
    );
  }

  Widget _form(){
    return Container(
      margin: EdgeInsets.only(left: ancho * 0.12,right: alto * 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: widget.key,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        child: Text('${translate(context: context, text: 'email')}:',
                          style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
                        )
                    ),
                    SizedBox(height: alto * 0.04,),
                    Container(
                      child: Text('${translate(context: context,text: 'Password')}:',
                        style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: TextFildGeneric(
                          onChanged: (text) {
                            nombre = text;
                            setState(() {});
                          },
                          labelStyle: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
                          textInputType: TextInputType.emailAddress,
                          sizeH: alto,
                          sizeW: ancho,
                          borderColor: WalkieTaskColors.color_B7B7B7,
                          sizeHeight: alto * 0.04,
                          textAlign: TextAlign.left,
                          textEditingController: _email,
                          initialValue: null,
                          sizeBorder: 1.2,
                          textCapitalization: TextCapitalization.none,
                        ),
                      ),
                      SizedBox(height: alto * 0.025,),
                      Container(
                        child: TextFildGeneric(
                          labelStyle: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
                          onChanged: (text) {
                            pasw = text;
                            setState(() {});
                          },
                          sizeH: alto,
                          sizeW: ancho,
                          borderColor: WalkieTaskColors.color_B7B7B7,
                          sizeBorder: 1.2,
                          sizeHeight: alto * 0.04,
                          textAlign: TextAlign.left,
                          textEditingController: _pass,
                          initialValue: null,
                          obscure: seePass,
                          suffixIcon: InkWell(
                            onTap: (){ setState(() {seePass = !seePass;});},
                            child: seePass ?
                            Icon(Icons.remove_red_eye_outlined,size: alto * 0.03,) :
                            Icon(Icons.remove_red_eye,size: alto * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: alto * 0.02,),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: alto * 0.038,
              width: ancho * 0.16,
              alignment: Alignment.centerRight,
              child: cargando
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  :
              RoundedButton(
                backgroundColor: WalkieTaskColors.primary,
                title: translate(context: context,text: 'LogIn'),
                onPressed: () => _save(),
                radius: 5.0,
                textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018,color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1),
              ),
            ),
          ),
          SizedBox(height: alto * 0.02,),
          Container(
            width: ancho,
            child: InkWell(
              child: Text(
                translate(context: context, text: 'ForgotYourPassword'),
                style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.02),
                textAlign: TextAlign.right,
              ),
              onTap: () async {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new RecoverPassword()));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _logo(){
    return Container(
      height: alto * 0.23,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset("assets/image/LogoWN.png").image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  conexionHttp conexionHispanos = new conexionHttp();
  Future<void> _save() async{
    setState(() { cargando = true; });
    if (nombre.isNotEmpty && pasw.isNotEmpty){
//          nombre = 'daniel.penya@imprevia.com';
//          nombre = 'jesus.cortez.1991@gmail.com';
//          pasw = '*Jc0473z01#';

      // nombre = 'ra@imprevia.com';
      // pasw = '*@Dmin1#';

      try{
        var response = await conexionHispanos.httpIniciarSesion(nombre,pasw);
        var value = jsonDecode(response.body);
        if(value['access_token'] != null){

          await finishApp();

          String token = value['access_token'];
          String tokenExp = value['access_token'];
          await SharedPrefe().setStringValue('unityToken','$token');
          await SharedPrefe().setStringValue('unityTokenExp','$tokenExp');

          UpdateData updateData = new UpdateData();
          Usuario myUser = await updateData.getMyUser();
          if(myUser != null){

            int userCheck = 1;
            var response3 = await conexionHispanos.httpCheckUser(nombre);
            var value3 = jsonDecode(response3.body);
            if(value3['status_code'] == 500){
              userCheck = 2;
            }
            if(value3['status_code'] != 500 && value3['status_code'] != 200){
              userCheck = 0;
              showAlert(translate(context: context,text: 'codeHasExpired'),Colors.red[400]);
              await Future.delayed(Duration(seconds: 3));
            }
            await SharedPrefe().setIntValue('unityLogin',userCheck);
            await SharedPrefe().setStringValue('unityEmail',myUser.email);
            await SharedPrefe().setStringValue('unityIdMyUser','${myUser.id}');
            await PermisoStore();
            await PermisoSonido();
            await PermisoPhotos();

            try{
              AuthService auth = provider.Provider.of<AuthService>(context,listen: false);
              auth.init();
            }catch(ex){
              print(ex);
            }
          }else{
            showAlert(translate(context: context,text: 'connectionError'),Colors.red[400]);
            cargando = false;
            setState(() {});
          }
        }
        if(value['message'] != null){
          showAlert(value['message'],Colors.red[400]);
          cargando = false;
          setState(() {});
        }
      }catch(e){
        print(e.toString());
        showAlert(translate(context: context,text: 'connectionError'),Colors.red[400]);
        cargando = false;
        setState(() {});
      }
    }else{
      showAlert(translate(context: context,text: 'PleaseFillOutAllFields'),Colors.red[400]);
      setState(() {
        cargando = false;
      });
    }
  }
}
