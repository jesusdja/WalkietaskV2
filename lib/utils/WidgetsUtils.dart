import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showAlert(String texto,Color color,{int sec = 1}){
  Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: sec,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0
  );
}