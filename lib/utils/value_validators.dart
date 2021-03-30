import 'package:flutter/cupertino.dart';
import 'package:walkietaskv2/utils/Globales.dart';

Map<String, dynamic> validateUserAddress(String input,BuildContext context) {
  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  const emailRegex = r"""^[a-zA-Z]+""";
  const userRegex = ""r'^[a-zA-Z0-9]+$'"";
  if (RegExp(emailRegex).hasMatch(input)) {
    if (input.length >= 4 && input.length < 10){
      if(RegExp(userRegex).hasMatch(input)){
        result['valid'] = true;
        result['sms'] = 'valido';
        return result;
      }else{
        result['valid'] = false;
        result['sms'] = translate(context: context,text: 'onlyLettersNumbers');
        return result;
      }
    }else{
      result['valid'] = false;
      result['sms'] = translate(context: context, text: 'usernameHaveCharacters');
      return result;
    }
  } else {
    result['valid'] = false;
    result['sms'] = translate(context: context, text: 'invalidUserLetter');
    return result;
  }
}

Map<String, dynamic> validateEmailAddress(String input,BuildContext context) {
  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  const emailRegex =
  r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(input)) {
    result['valid'] = true;
    result['sms'] = 'Correo valido.';
    return result;
  } else {
    result['valid'] = false;
    result['sms'] = translate(context: context, text: 'invalidEmail');
    return result;
  }
}


Map<String, dynamic> validatePassword(String input,BuildContext context) {
  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  // String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
  String oneNumber = r'^.*[0-9].*$';
  String oneLowerCase = r'^.*[a-z].*$';
  String oneUpperCase = r'^.*[A-Z].*$';
  if (input.length < 8) {
    result['valid'] = false;
    result['sms'] = translate(context: context, text: 'invalidPass_1');
    return result;
  } else if (!RegExp(oneNumber).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = translate(context: context, text: 'invalidPass_2');
    return result;
  } else if (!RegExp(oneLowerCase).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = translate(context: context, text: 'invalidPass_3');
    return result;
  } else if (!RegExp(oneUpperCase).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = translate(context: context, text: 'invalidPass_4');
    return result;
  }
  result['valid'] = true;
  result['sms'] = 'valido.';
  return result;
}