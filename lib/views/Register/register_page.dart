import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Register/widgets/form_register.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  double sizeH = 0;
  double sizeW = 0;

  @override
  Widget build(BuildContext context) {
    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      appBar: appBarWidget( sizeH,()=>Navigator.of(context).pop(),'Crear Cuenta'),
      body: Container(
        margin: EdgeInsets.only(left: 24,right: 24),
        height: sizeH,
        width: sizeW,
        child: FormRegister()
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
