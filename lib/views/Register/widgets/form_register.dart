import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:walkietaskv2/bloc/blocUserCheck.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Permisos.dart';
import 'package:walkietaskv2/services/auth.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/textfield_generic_verific.dart';
import 'package:walkietaskv2/utils/value_validators.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/utils/finish_app.dart';

class FormRegister extends StatefulWidget {
  FormRegister({this.contextLogin});
  final BuildContext contextLogin;

  @override
  _FormRegisterState createState() => _FormRegisterState();
}

class _FormRegisterState extends State<FormRegister> {
  FocusNode focusNodeName = FocusNode();
  FocusNode focusNodeLastName = FocusNode();
  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodeUser = FocusNode();
  FocusNode focusNodePass = FocusNode();

  bool isLoad = false;
  bool showError = false;
  bool showErrorCheck = false;
  bool isAccepted = false;
  bool seePass = true;

  String name = '';
  String surname = '';
  String email = '';
  String user = '';
  String pass = '';

  double sizeH = 0;
  double sizeW = 0;
  int checkUser = 0;

  BlocUserCheck _blocUserCheck;
  StreamSubscription streamSubscriptionUser;

  @override
  void initState() {
    super.initState();
    _blocUserCheck = BlocUserCheck();
    listenBlocCheck();
  }

  void listenBlocCheck(){
    streamSubscriptionUser = _blocUserCheck.outList.listen((newVal) {
      setState(() {
        checkUser = newVal;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    focusNodeUser.dispose();
    focusNodeName.dispose();
    focusNodeLastName.dispose();
    focusNodeEmail.dispose();
    focusNodePass.dispose();
    streamSubscriptionUser.cancel();
    _blocUserCheck.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;

    Map<String, FocusNode> mapError = {};

    Widget userErrorW = Container();
    if(showErrorCheck  && !validateUserAddress(user)['valid']){
      userErrorW = _error(sizeW,validateUserAddress(user)['sms']);
      checkUser = 0;
    }

    if(showError && user.isEmpty){
      userErrorW = _error(sizeW,'Este espacio es requerido.');
      checkUser = 0;
    }

    Widget nameErrorW = Container();
    if (showError && name.isEmpty) {
      nameErrorW = _error(sizeW, 'Este espacio es requerido');
      if (mapError.isEmpty) mapError['error'] = focusNodeName;
    }
    Widget lastNameErrorW = Container();
    if (showError && surname.isEmpty) {
      lastNameErrorW = _error(sizeW,'Este espacio es requerido',);
      if (mapError.isEmpty) mapError['error'] = focusNodeLastName;
    }

    Widget emailErrorW = Container();
    if (showError && !validateEmailAddress(email)['valid']) {
      emailErrorW = _error(sizeW,validateEmailAddress(email)['sms'],);
      if (mapError.isEmpty) mapError['error'] = focusNodeEmail;
    }

    Widget passErrorW = Container();
    if (showError && !validatePassword(pass)['valid']) {
      passErrorW = _error(sizeW,validatePassword(pass)['sms'],);
      if (mapError.isEmpty) mapError['error'] = focusNodePass;
    }

    TextStyle textStyle1 = WalkieTaskStyles().styleNunitoRegular(size: sizeH * 0.02);
    TextStyle textStyle2 = WalkieTaskStyles().styleNunitoBlack(size: sizeH * 0.02);
    TextStyle textStyle3 = WalkieTaskStyles().styleNunitoRegular(size: sizeH * 0.018);

    return isLoad
        ? Center(
      child: CircularProgressIndicator(),
    )
        : GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        margin: EdgeInsets.only(left: 3, right: 3),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                width: sizeW,
                child: Text(
                  'Crea tu cuenta para poder comenzar a enviar y recibir walkietasks.',
                  style: textStyle1,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: sizeW,
                child: Text('Tus datos:',
                  style: textStyle2
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: sizeW,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: sizeW * 0.25,
                      margin: EdgeInsets.only(right: sizeW * 0.025),
                      child: Text(
                        'Nombre:',
                        style: textStyle1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: TextFildGeneric(
                        labelStyle: textStyle1,
                        focusNode: focusNodeName,
                        initialValue: name,
                        onChanged: (String value) {
                          setState(() {
                            name = value;
                          });
                        },
                        sizeW: sizeW,
                        sizeH: sizeH,
                        sizeHeight: sizeH * 0.045,
                      ),
                    )
                  ],
                ),
              ),
              nameErrorW,
              SizedBox(
                height: 10,
              ),
              Container(
                width: sizeW,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: sizeW * 0.25,
                      margin: EdgeInsets.only(right: sizeW * 0.025),
                      child: Text(
                        'Apellido:',
                        style: textStyle1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: TextFildGeneric(
                        labelStyle: textStyle1,
                        focusNode: focusNodeLastName,
                        initialValue: surname,
                        onChanged: (String value) {
                          setState(() {
                            surname = value;
                          });
                        },
                        sizeW: sizeW,
                        sizeH: sizeH,
                        sizeHeight: sizeH * 0.045,
                      ),
                    )
                  ],
                ),
              ),
              lastNameErrorW,
              SizedBox(
                height: 10,
              ),
              Container(
                width: sizeW,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: sizeW * 0.25,
                      margin: EdgeInsets.only(right: sizeW * 0.025),
                      child: Text(
                        'Correo:',
                        style: textStyle1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: TextFildGeneric(
                        labelStyle: textStyle1,
                        focusNode: focusNodeEmail,
                        initialValue: email,
                        textInputType: TextInputType.emailAddress,
                        onChanged: (String value) {
                          setState(() {
                            email = value;
                          });
                        },
                        sizeW: sizeW,
                        sizeH: sizeH,
                        sizeHeight: sizeH * 0.045,
                        textCapitalization: TextCapitalization.none,
                      ),
                    )
                  ],
                ),
              ),
              emailErrorW,
              SizedBox(
                height: 10,
              ),
              Container(
                width: sizeW,
                child: Text('Usuario:',
                    style: textStyle2
                ),
              ),
              Container(
                width: sizeW,
                child: Text(
                  'El nombre con el que aparecerás en Walkietask',
                  style: textStyle3
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: sizeW,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: sizeW * 0.25,
                      margin: EdgeInsets.only(right: sizeW * 0.025),
                      child: Text(
                        'Usuario:',
                        style: textStyle1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: TextFildGenericVerific(
                        focusNode: focusNodeUser,
                        initialValue: user,
                        onChanged: (String value) {
                          if (value.isNotEmpty && validateUserAddress(user)['valid']) {
                            showErrorCheck = false;
                            user = value;
                            _blocUserCheck.check(value);
                          }else{
                            user = value;
                            showErrorCheck = true;
                            checkUser = 0;
                          }
                          setState(() {});
                        },
                        sizeW: sizeW,
                        sizeH: sizeH,
                        check: checkUser,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: sizeH * 0.01,
              ),
              userErrorW,
              SizedBox(
                height: 10,
              ),
              Container(
                width: sizeW,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: sizeW * 0.25,
                      margin: EdgeInsets.only(top: sizeH * 0.01, right: sizeW * 0.025),
                      child: Text(
                        'Contraseña:',
                        style: textStyle1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          TextFildGeneric(
                            labelStyle: textStyle1,
                            focusNode: focusNodePass,
                            initialValue: pass,
                            onChanged: (String value) {
                              setState(() {
                                pass = value;
                              });
                            },
                            textCapitalization: TextCapitalization.sentences,
                            sizeW: sizeW,
                            sizeH: sizeH,
                            sizeHeight: sizeH * 0.045,
                            obscure: seePass,
                            suffixIcon: InkWell(
                              onTap: (){ setState(() {seePass = !seePass;});},
                              child: seePass ?
                              Icon(Icons.remove_red_eye_outlined,size: sizeH * 0.03,) :
                              Icon(Icons.remove_red_eye,size: sizeH * 0.03),
                            ),
                          ),
                          Container(
                            width: sizeW,
                            child: Text(
                                'Debe incluir minúsculas, mayúsculas y números.',
                                style: textStyle3
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 5,),
              passErrorW,
              SizedBox(height: sizeH * 0.1,),
              _buttonPressSaveUser(),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _error(double sizeW,String texto,) {
    return Container(
      width: sizeW,
      child: Row(
        children: <Widget>[
          Container(
            width: sizeW * 0.25,
            margin: EdgeInsets.only(right: sizeW * 0.025),
            child: Text(
              '',
              style: WalkieTaskStyles().styleNunitoRegular(size: sizeH * 0.02),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
              child: Text(
                texto,
                style: WalkieTaskStyles().styleNunitoRegular(size: sizeH * 0.02,color: WalkieTaskColors.color_E07676),
              ),
          )
        ],
      ),
    );
  }

  Widget _buttonPressSaveUser(){
    return Container(
      width: sizeW,
      child: Center(
        child: isAccepted ?
        CircularProgressIndicator()
        :
        RoundedButton(
          borderColor: WalkieTaskColors.primary,
          width: sizeW * 0.2,
          height: sizeH * 0.05,
          radius: 5.0,
          title: 'Aceptar',
          textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: sizeH * 0.02, color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
          backgroundColor: WalkieTaskColors.primary,
          onPressed: () async{
            bool isError = false;
            setState(() {
              isLoad = true;
            });

            if(name.isNotEmpty && !showErrorCheck && surname.isNotEmpty &&
                validateEmailAddress(email)['valid'] &&
                validatePassword(pass)['valid']){
              conexionHttp connectionHttp = new conexionHttp();
              try{
                Map<String,dynamic> body = {
                  'name' : name,
                  'surname' : surname,
                  'username' : user,
                  'email' : email,
                  'password' : pass,
                  'password_confirmation' : pass,
                };
                var response = await connectionHttp.httpRegisterUser(body);
                var value = jsonDecode(response.body);
                print(value);
                if(response.statusCode == 201){
                  var response2 = await connectionHttp.httpIniciarSesion(body['email'], body['password']);
                  var value2 = jsonDecode(response2.body);
                  if(value2['access_token'] != null){

                    await finishApp();

                    String token = value2['access_token'];
                    String tokenExp = value2['access_token'];
                    await SharedPrefe().setStringValue('unityToken','$token');
                    await SharedPrefe().setStringValue('unityTokenExp','$tokenExp');
                    UpdateData updateData = new UpdateData();
                    Usuario myUser = await updateData.getMyUser();
                    if(myUser != null){
                      await SharedPrefe().setIntValue('unityLogin',2);
                      await SharedPrefe().setStringValue('unityEmail',myUser.email);
                      await SharedPrefe().setStringValue('unityIdMyUser','${myUser.id}');
                      await PermisoStore();
                      await PermisoSonido();
                      await PermisoPhotos();
                      try{
                        AuthService auth = provider.Provider.of<AuthService>(widget.contextLogin);
                        auth.init();
                        Navigator.of(context).pop();
                      }catch(ex){
                        print(ex);
                        showAlert('Error al enviar datos.',Colors.red[400]);
                      }
                    }else{
                      showAlert('Error al enviar datos.',Colors.red[400]);
                    }
                  }
                }else{
                  if(value['errors'] != null){
                    try{
                      Map mapValue = value['errors'] as Map;
                      mapValue.forEach((key, value) {
                        List listValue = value as List;
                        listValue.forEach((element) {
                          String errorElement = element as String;
                          errorElement = errorElement.replaceAll('username', 'Usuario');
                          showAlert(errorElement,Colors.red[400]);
                        });
                      });
                    }catch(e){
                      showAlert('Error al enviar datos.',Colors.red[400]);
                    }
                  }else{
                    showAlert('Error al enviar datos.',Colors.red[400]);
                  }
                }

              }catch(e){
                print(e.toString());
                showAlert('Error al enviar datos.',Colors.red[400]);
              }
            }else{
              isError = true;
            }
            setState(() {
              isLoad = false;
              showError = isError;
            });
          },
        ),
      ),
    );
  }
}
