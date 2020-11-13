import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Register/widgets/form_register.dart';

class RegisterPage extends StatelessWidget {

  RegisterPage({this.contextLogin});
  final BuildContext contextLogin;

  @override
  Widget build(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      appBar: appBarWidget( sizeH,()=>Navigator.of(context).pop(),'Crear Cuenta'),
      body: Container(
        margin: EdgeInsets.only(left: 24,right: 24),
        height: sizeH,
        width: sizeW,
        child: FormRegister(contextLogin: contextLogin,)
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
