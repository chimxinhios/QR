import 'dart:async';

class CameraBloc {
  StreamController _streamController = new StreamController();
  StreamSink get sink => _streamController.sink;
  Stream get stream => _streamController.stream;

  CameraBloc() {
    _streamController = StreamController.broadcast();
  }
  void dispose() {
    _streamController.close();
  }

  
}
