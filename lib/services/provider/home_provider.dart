import 'package:flutter/cupertino.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class HomeProvider with ChangeNotifier{

  HomeProvider(){
    getValue();
  }

  int _posPersonal = 0;

  int get posPersonal => this._posPersonal;

  set posPersonal( int value){
    addValue(value);
    _posPersonal = value;
    notifyListeners();
  }

  Future<void> addValue(int value) async{
    await SharedPrefe().setIntValue('posPersonal', value);
  }
  Future<void> getValue() async{
    _posPersonal = await SharedPrefe().getValue('posPersonal');
  }

}