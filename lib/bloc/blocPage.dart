import 'dart:async';

class BlocPage {

  var _controller = StreamController<int>.broadcast();
  Stream<int> get outList => _controller.stream;
  Sink<int> get inList => _controller.sink;

  void dispose() {
    _controller.close();
  }
}