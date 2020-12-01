import 'dart:async';
import 'dart:convert';
import 'package:walkietaskv2/services/Conexionhttp.dart';

class BlocUserCheck {

  var _controller = StreamController<int>.broadcast();
  Stream<int> get outList => _controller.stream;
  Sink<int> get inList => _controller.sink;

  Future<void> check(String userName) async{
    inList.add(3);
    conexionHttp connectionHttp = new conexionHttp();
    try{
      var response = await connectionHttp.httpCheckUserRegister(userName);
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        inList.add(1);
      }else{
        inList.add(2);
      }
    }catch(e){
      inList.add(2);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}