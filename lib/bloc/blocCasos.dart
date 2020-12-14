import 'dart:async';

class BlocCasos {

  var _patronController = StreamController<bool>.broadcast();
  Stream<bool> get outList => _patronController.stream;
  Sink<bool> get inList => _patronController.sink;

  blocClientCasos(){}

  void dispose() {
    _patronController.close();
  }
}