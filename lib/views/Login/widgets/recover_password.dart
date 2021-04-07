import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/value_validators.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class RecoverPassword extends StatefulWidget {
  @override
  _RecoverPasswordState createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {

  double sizeH = 0;
  double sizeW = 0;

  bool isLoad = false;
  bool isAccepted = false;

  TextEditingController _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    TextStyle textStyle1 = WalkieTaskStyles().styleNunitoRegular(size: sizeH * 0.02);

    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      appBar: appBarWidget( sizeH,()=>Navigator.of(context).pop(),translate(context: context,text: 'ForgotYourPassword')),
      body: Container(
        margin: EdgeInsets.only(left: 24,right: 24),
        height: sizeH,
        width: sizeW,
        child: isLoad
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
                  SizedBox(height: 20,),
                  Container(
                    width: sizeW,
                    child: Text(
                      translate(context: context, text: 'typeRecoveryEmail'),
                      style: textStyle1,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: sizeH * 0.06,),
                  Container(
                    width: sizeW,
                    child: Text(
                      translate(context: context,text: 'emailOrUsername'),
                      style: textStyle1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: sizeH * 0.01,),
                  Container(
                    width: sizeW,
                    child: Center(
                      child: Container(
                        width: sizeW * 0.5,
                        child: TextFildGeneric(
                          textEditingController: _controllerEmail,
                          initialValue: null,
                          labelStyle: textStyle1,
                          textInputType: TextInputType.emailAddress,
                          sizeH: sizeH,
                          sizeW: sizeW,
                          borderColor: WalkieTaskColors.color_B7B7B7,
                          sizeBorder: 1.2,
                          sizeHeight: sizeH * 0.045,
                          textAlign: TextAlign.left,
                          textCapitalization: TextCapitalization.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sizeH * 0.06,),
                  _buttonPressSaveUser(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  conexionHttp conexionHispanos = new conexionHttp();
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
          height: sizeH * 0.045,
          radius: 5.0,
          title: translate(context: context,text: 'ok'),
          textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: sizeH * 0.02, color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
          backgroundColor: WalkieTaskColors.primary,
          onPressed: () async{
            setState(() {
              isAccepted = true;
            });
            if(validateEmailAddress(_controllerEmail.text,context)['valid']){
              try{
                var response = await conexionHispanos.httpRecoverPass(_controllerEmail.text);
                var value = jsonDecode(response.body);
                if(value['status_code'] == 200){
                  _controllerEmail.text = '';
                  setState(() {});
                  showAlert('Enviado.!',WalkieTaskColors.color_89BD7D);
                }else{
                  String error = translate(context: context, text: 'problemSendingInformation');
                  if(value['message'] != null) error = value['message'];
                  showAlert(error,Colors.red[400]);
                }
              }catch(e){
                print(e.toString());
                showAlert(translate(context: context,text: 'connectionError'),Colors.red[400]);
                setState(() {});
              }
            }else{
              showAlert(translate(context: context, text: 'enterValidEmail'),Colors.red[400]);
            }


            setState(() {
              isAccepted = false;
            });
            // Navigator.push(context, new MaterialPageRoute(
            //     builder: (BuildContext context) => new RegisterCode()));
          },
        ),
      ),
    );
  }

  Widget appBarWidget(double sizeH,Function() onTap,String title){
    return AppBar(
      leading: InkWell(
        child: Icon(Icons.arrow_left,size: sizeH * 0.07,color: WalkieTaskColors.white,),
        onTap: onTap,
      ),
      title: Text(title,style: WalkieTaskStyles().styleNunitoBold()),
    );
  }
}
