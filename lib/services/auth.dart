import 'package:flutter/cupertino.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

enum Status { Logo,Login,home,code}

class AuthService with ChangeNotifier{
  Status _status = Status.Logo;

//  "email": "daniel.penya@imprevia.com",
//  "password": "*D@p3N14#",

  AuthService.instance();

  Status get status => _status;

  Future init() async {
    int counter = await SharedPrefe().getValue('unityLogin');

    int versiondb = await SharedPrefe().getValue('unityInit');
    if(versiondb == null || versiondb != 5){
      await SharedPrefe().setIntValue('unityInit', 5);
      await DatabaseProvider.db.deleteDatabaseInstance();
    }

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