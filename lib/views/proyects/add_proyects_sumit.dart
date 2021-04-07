import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocPage.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';


class AddProyectsSumit extends StatefulWidget {

  AddProyectsSumit(this.blocPage);

  final BlocPage blocPage;

  @override
  AddProyectsSumitState createState() => AddProyectsSumitState();
}

class AddProyectsSumitState extends State<AddProyectsSumit> {

  double alto = 0;
  double ancho = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ancho,
          child: Text(translate(context: context, text: 'projectCreated'),
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696), textAlign: TextAlign.right,),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            child: Center(
              child: Container(
                width: ancho * 0.1,
                height: alto * 0.06,
                child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: WalkieTaskColors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: contenido(),
      ),
    );
  }

  Widget contenido(){
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05),
        child: Column(
          children: <Widget>[
            SizedBox(height: alto * 0.1,),
            Container(
              width: ancho,
              child: Text(translate(context: context, text: 'notifiedUsers')
              ,textAlign: TextAlign.center,
              style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022, color: WalkieTaskColors.color_4D4D4D, fontWeight: FontWeight.bold, spacing: 1),),
            ),
            SizedBox(height: alto * 0.08,),
            RoundedButton(
              backgroundColor: WalkieTaskColors.primary,
              title: translate(context: context, text: 'sendTask'),
              radius: 5.0,
              textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022,color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
              width: ancho * 0.35,
              height: alto * 0.035,
              onPressed: (){
                widget.blocPage.inList.add(1);
                Navigator.of(context).pop();
              },
            ),
            SizedBox(height: alto * 0.03,),
            RoundedButton(
              backgroundColor: WalkieTaskColors.primary,
              title: translate(context: context, text: 'back'),
              radius: 5.0,
              textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022,color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
              width: ancho * 0.35,
              height: alto * 0.035,
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
