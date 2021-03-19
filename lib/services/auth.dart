import 'package:flutter/cupertino.dart';
import 'package:walkietaskv2/utils/finish_app.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

enum Status { Logo,Login,home,code}

class AuthService with ChangeNotifier{
  Status _status = Status.Logo;

//  "email": "daniel.penya@imprevia.com",
//  "password": "*D@p3N14#",

  AuthService.instance();

  Status get status => _status;

  Future init() async {

    int versiondb = await SharedPrefe().getValue('unityInit');
    if(versiondb == null || versiondb != 17){
      await SharedPrefe().setIntValue('unityInit', 17);
      await finishApp();
    }

    int counter = await SharedPrefe().getValue('unityLogin');

    if(counter != null){
      if(counter == 0){
        _status = Status.Login;
      }
      if(counter == 1){
        _status = Status.home;
      }
      if(counter == 2){
        _status = Status.code;
      }
    }else{
      _status = Status.Login;
    }
    notifyListeners();
  }
}