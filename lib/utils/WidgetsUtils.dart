import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showAlert(String texto,Color color){
  Fluttertoast.showToast(
      msg: texto,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0
  );
}