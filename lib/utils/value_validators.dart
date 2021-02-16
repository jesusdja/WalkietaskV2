Map<String, dynamic> validateUserAddress(String input) {
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
        result['sms'] = 'Solo se permiten letras y numeros.';
        return result;
      }
    }else{
      result['valid'] = false;
      result['sms'] = 'Usuario debe contener entre 5 y 10 caracteres.';
      return result;
    }
  } else {
    result['valid'] = false;
    result['sms'] = 'Usuario invalido. Debe comenzar con una letra.';
    return result;
  }
}

Map<String, dynamic> validateEmailAddress(String input) {
  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  const emailRegex =
  r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(input)) {
    result['valid'] = true;
    result['sms'] = 'Correo valido.';
    return result;
  } else {
    result['valid'] = false;
    result['sms'] = 'Correo invalido.';
    return result;
  }
}


Map<String, dynamic> validatePassword(String input) {
  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  // String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
  String oneNumber = r'^.*[0-9].*$';
  String oneLowerCase = r'^.*[a-z].*$';
  String oneUpperCase = r'^.*[A-Z].*$';
  if (input.length < 8) {
    result['valid'] = false;
    result['sms'] = 'Usá mínimo 8 caracteres';
    return result;
  } else if (!RegExp(oneNumber).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = 'Debe contener al menos un número';
    return result;
  } else if (!RegExp(oneLowerCase).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = 'Debe contener al menos una minúscula';
    return result;
  } else if (!RegExp(oneUpperCase).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = 'Debe contener al menos una mayúscula';
    return result;
  }
  result['valid'] = true;
  result['sms'] = 'valido.';
  return result;
}