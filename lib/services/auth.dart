import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { Logo,Login,home}

class AuthService with ChangeNotifier{
  Status _status = Status.Logo;

//  "email": "daniel.penya@imprevia.com",
//  "password": "*D@p3N14#",

  AuthService.instance();

  Status get status => _status;

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('unityLogin');
    //await Future.delayed(Duration(seconds: 3));

    if(counter != null){
      if(counter == 0){
        _status = Status.Login;
      }
      if(counter == 1){
        _status = Status.home;
      }
    }else{
      _status = Status.Login;
    }
    notifyListeners();
  }
}