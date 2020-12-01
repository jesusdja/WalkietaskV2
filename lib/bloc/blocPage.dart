import 'dart:async';
import 'dart:convert';
import 'package:walkietaskv2/services/Conexionhttp.dart';

class BlocPage {

  var _controller = StreamController<int>.broadcast();
  Stream<int> get outList => _controller.stream;
  Sink<int> get inList => _controller.sink;

  @override
  void dispose() {
    _controller.close();
  }
}