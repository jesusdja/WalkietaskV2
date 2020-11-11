import 'dart:async';
import 'dart:convert';

import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';

class BlocUser {

  var _PatronController = StreamController<bool>.broadcast();
  Stream<bool> get outList => _PatronController.stream;
  Sink<bool> get inList => _PatronController.sink;

  blocClientUser(){}

  @override
  void dispose() {
    _PatronController.close();
  }
}