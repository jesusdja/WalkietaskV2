import 'dart:async';

class BlocTask {

  var _patronController = StreamController<bool>.broadcast();
  Stream<bool> get outList => _patronController.stream;
  Sink<bool> get inList => _patronController.sink;

  void dispose() {
    _patronController.close();
  }
}