import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Future<void> flushBarNotification({
  @required BuildContext context,
  Widget messageText,
  Widget avatar,
  Widget titleText,
}) async{
  Flushbar(
    titleText: titleText,
    messageText:  messageText,
    duration:  Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    backgroundColor: Colors.black.withOpacity(0.6),
    icon: avatar,
  )..show(context);
}