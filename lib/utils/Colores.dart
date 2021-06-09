import 'package:flutter/material.dart';


class WalkieTaskColors {
  ///predominant color
  static const Color primary = Color(0xFF4EA0F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color yellow = Color(0xFFFFD803);

  static const Color color_E2E2E2 = Color(0xFFE2E2E2);
  static const Color color_E3E3E3 = Color(0xFFE3E3E3);
  static const Color grey = Color(0xFFD1D1D1);
  static const Color color_B7B7B7 = Color(0xFFB7B7B7);
  static const Color color_ACACAC = Color(0xFFACACAC);
  static const Color color_BABABA = Color(0xFFBABABA);
  static const Color color_969696 = Color(0xFF969696);
  static const Color color_BCBCBC = Color(0xFFBCBCBC);
  static const Color color_FAE438 = Color(0xFFFAE438);
  static const Color color_E07676 = Color(0xFFE07676);
  static const Color color_EA7575 = Color(0xFFEA7575);
  static const Color color_DD7777 = Color(0xFFDD7777);
  static const Color color_E8F4FA = Color(0xFFE8F4FA);
  static const Color color_76ADE3 = Color(0xFF76ADE3);
  static const Color color_4EA0F0 = Color(0xFF4EA0F0);
  static const Color color_4D9DFA = Color(0xFF4D9DFA);
  static const Color color_555555 = Color(0xFF555555);
  static const Color color_4D4D4D = Color(0xFF4D4D4D);
  static const Color color_3C3C3C = Color(0xFF3C3C3C);
  static const Color color_FFF5B3 = Color(0xFFFCF6CC);
  static const Color color_89BD7D = Color(0xFF89BD7D);
  static const Color color_8CD59B = Color(0xFF8CD59B);
}

Color colorfondotext = Color(0xFFCAEDC7);
Color colorSliderListo = Color(0xFF89BD7D);
Color colorSonidoAct = Color(0xFF76B7F8);
Color colorButtonBlueAT = Color(0xFF76B7F8);
Color colorChat = Color(0xFF8298C3);
Color colorSliderTrabajando = Color(0xFF8DA6DE);

Color colorfondoDetalle = Color(0xFFFFFFFF);
Color colorFondoChat = Color(0xFFF4F4F4);
Color colorFondoSend = Color(0xFFEFEFEF);
Color colorfondoSelectUser = Color(0xFFEBF4FD);
Color colorletrasbuttonAT = Color(0xFFD5D5D5);
Color colorSubtitulo = Color(0xFFD1D1D1);
Color colorTareasEnviadas = Color(0xFFCCCCCC);
Color bordeCirculeAvatar = Color(0xFFFFFFFF);
Color colorBordeHome = Color(0xFFBFBFBF);
Color colorBordeOpc = Color(0xFFBABABA);
Color letrasbuscar = Color(0xFF969696);
Color colortitulo = Color(0xFF969696);
Color colorfuenteDetwalle = Color(0xFF5A5A5A);
Color coloraudioDetwalle = Color(0xFF5A5A5A);
Color colortitulo2 = Color(0xFF555555);
Color colorLetrastext = Color(0xFF555555);
Color colortitulo1 = Color(0xFF3C3C3C);

TextStyle estiloLetras(double fuente,Color color, {String fontFamily : 'helveticaneue',FontWeight negrita : FontWeight.normal}){
  TextStyle st = TextStyle(
    fontSize: fuente,
    color: color,
    fontWeight: negrita,
    letterSpacing: 1,
    fontFamily: fontFamily,

  );
  return st;
}

var borderHome = OutlineInputBorder(
  borderSide: const BorderSide(color: Colors.grey, width: 1),
  borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
);