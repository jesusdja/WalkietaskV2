import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class Abbout extends StatefulWidget {
  @override
  _AbboutState createState() => _AbboutState();
}

class _AbboutState extends State<Abbout> {

  double ancho = 0;
  double alto = 0;

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.only(right: ancho * 0.1),
          width: ancho,
          child: Text(translate(context: context, text: 'text_title'),
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696),textAlign: TextAlign.right,),        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey,size: alto * 0.04,),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: alto * 0.1,),
            _logo(),
            SizedBox(height: alto * 0.06,),
            Container(
              width: ancho,
              margin: EdgeInsets.symmetric(horizontal: ancho * 0.06),
              child: Text(translate(context: context, text: 'text_about'),
              style: WalkieTaskStyles().styleNunitoRegular(
                size: alto * 0.025,
                color: WalkieTaskColors.color_969696),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo(){
    return Container(
      height: alto * 0.23,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ViewImage().assetsImage("assets/image/LogoWN.png").image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
