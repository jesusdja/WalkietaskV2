import 'dart:async';
import 'dart:convert';

import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';

class BlocProgress {

  var _progressController = StreamController<Map<String,dynamic>>.broadcast();
  Stream<Map<String,dynamic>> get outList => _progressController.stream;
  Sink<Map<String,dynamic>> get inList => _progressController.sink;

  @override
  void dispose() {
    _progressController.close();
  }
}