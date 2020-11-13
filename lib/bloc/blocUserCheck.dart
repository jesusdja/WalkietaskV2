import 'dart:async';
import 'dart:convert';

import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';

class BlocUserCheck {

  var _controller = StreamController<int>.broadcast();
  Stream<int> get outList => _controller.stream;
  Sink<int> get inList => _controller.sink;

  Future<void> check(String userName) async{
    inList.add(3);
    await Future.delayed(Duration(seconds: 2));
    inList.add(1);
  }

  @override
  void dispose() {
    _controller.close();
  }
}