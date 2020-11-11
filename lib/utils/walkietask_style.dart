import 'package:flutter/material.dart';

class WalkieTaskStyles {

  TextStyle styleAvenirBook({
    double size,
    Color color,
    double h,
    TextDecoration textDecoration,
    FontWeight fontWeight: FontWeight.normal,
    double spacing: 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: 'Avenir-Book',
      fontSize: size,
      height: h,
      decoration: textDecoration,
      fontWeight: fontWeight,
      letterSpacing: spacing,
    );
  }

  TextStyle styleNunitoRegular({
    double size,
    Color color,
    double h,
    TextDecoration textDecoration,
    FontWeight fontWeight: FontWeight.normal,
    double spacing: 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: 'Nunito-Regular',
      fontSize: size,
      height: h,
      decoration: textDecoration,
      fontWeight: fontWeight,
      letterSpacing: spacing,
    );
  }

  TextStyle styleNunitoBold({
    double size,
    Color color,
    double h,
    TextDecoration textDecoration,
    FontWeight fontWeight: FontWeight.normal,
    double spacing: 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: 'Nunito-Bold',
      fontSize: size,
      height: h,
      decoration: textDecoration,
      fontWeight: fontWeight,
      letterSpacing: spacing,
    );
  }

  TextStyle styleNunitoBlack({
    double size,
    Color color,
    double h,
    TextDecoration textDecoration,
    FontWeight fontWeight: FontWeight.normal,
    double spacing: 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: 'Nunito-Black',
      fontSize: size,
      height: h,
      decoration: textDecoration,
      fontWeight: fontWeight,
      letterSpacing: spacing,
    );
  }

  TextStyle styleHelveticaneueRegular({
    double size,
    Color color,
    double h,
    TextDecoration textDecoration,
    FontWeight fontWeight: FontWeight.normal,
    double spacing: 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: 'helveticaneue-Regular',
      fontSize: size,
      height: h,
      decoration: textDecoration,
      fontWeight: fontWeight,
      letterSpacing: spacing,
    );
  }

  TextStyle styleHelveticaNeueBold({
    double size,
    Color color,
    double h,
    TextDecoration textDecoration,
    FontWeight fontWeight: FontWeight.normal,
    double spacing: 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: 'HelveticaNeu-Bold',
      fontSize: size,
      height: h,
      decoration: textDecoration,
      fontWeight: fontWeight,
      letterSpacing: spacing,
    );
  }
}
