import 'dart:async';

class BlocProgress {

  var _progressController = StreamController<Map<String,dynamic>>.broadcast();
  Stream<Map<String,dynamic>> get outList => _progressController.stream;
  Sink<Map<String,dynamic>> get inList => _progressController.sink;

  void dispose() {
    _progressController.close();
  }
}