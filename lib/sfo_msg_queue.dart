import 'dart:async';

class SfoMsgQueue {
  final StreamController<dynamic> _controller;
  SfoMsgQueue._(this._controller);

  static Future<SfoMsgQueue> create(Future<void> Function(dynamic) msgHandler) async {
    final StreamController<dynamic> controller = StreamController<dynamic>();
    controller.stream.asyncMap(
          (message) async {
            await msgHandler(message);
      },
    ).listen((_) {});

    return SfoMsgQueue._(controller);
  }

  void send(dynamic message) {
    _controller.sink.add(message);
  }

  void close() {
    _controller.close();
  }

  Future<void> waitComplete() async {
    await _controller.done;
  }
}