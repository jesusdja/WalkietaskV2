import 'dart:async';

class BlocUser {

  var _patronController = StreamController<bool>.broadcast();
  Stream<bool> get outList => _patronController.stream;
  Sink<bool> get inList => _patronController.sink;

  blocClientUser(){}

  void dispose() {
    _patronController.close();
  }
}