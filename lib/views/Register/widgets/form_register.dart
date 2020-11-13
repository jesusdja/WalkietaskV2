import 'dart:async';

import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocUserCheck.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/textfield_generic_verific.dart';
import 'package:walkietaskv2/utils/value_validators.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Register/widgets/register_code.dart';

class FormRegister extends StatefulWidget {
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
    // TODO: implement initState
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
                            obscure: true,
                            onChanged: (String value) {
                              setState(() {
                                pass = value;
                              });
                            },
                            sizeW: sizeW,
                            sizeH: sizeH,
                            sizeHeight: sizeH * 0.045,
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
              isAccepted = true;
            });
            await Future.delayed(Duration(seconds: 3));

            isError = true;

            setState(() {
              isAccepted = false;
              showError = isError;
            });
            // Navigator.push(context, new MaterialPageRoute(
            //     builder: (BuildContext context) => new RegisterCode()));
          },
        ),
      ),
    );
  }
}
