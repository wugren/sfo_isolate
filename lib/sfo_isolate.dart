import 'dart:async';
import 'dart:isolate';

class _CloseMsg {

}

class _IsolateParams {
  final SendPort _sendPort;
  final Future<void> Function(dynamic) _msgHandler;
  _IsolateParams._(this._sendPort, this._msgHandler);
}

class SfoIsolate {
  final Isolate _isolate;
  final SendPort _msgSendPort;
  final Completer<void> _exitCompleter;

  SfoIsolate._(this._msgSendPort, this._isolate, this._exitCompleter);

  static void _isolateProc(_IsolateParams params) {
    final recievePort = ReceivePort();
    params._sendPort.send(recievePort.sendPort);
    recievePort.listen((message) async {
      if (message is SendPort) {
        message.send(message);
      } else if (message is _CloseMsg) {
        recievePort.close();
      } else {
        await params._msgHandler(message);
      }
    });
  }

  static Future<SfoIsolate> create(Future<void> Function(dynamic) msgHandler ) async {
    final mainRecievePort = ReceivePort();
    final isolate = await Isolate.spawn(_isolateProc,
        _IsolateParams._(mainRecievePort.sendPort, msgHandler),
        onError: mainRecievePort.sendPort,
        onExit: mainRecievePort.sendPort
    );

    Completer<void> exitCompleter = Completer();
    Completer<SendPort> completer = Completer();
    mainRecievePort.listen((message) {
      if (message == null) {
        mainRecievePort.close();
        exitCompleter.complete();
      }
      if (message is SendPort) {
        completer.complete(message);
      }
    });

    final msgSendPort = await completer.future;

    return SfoIsolate._(msgSendPort, isolate, exitCompleter);
  }

  void send(dynamic message) {
    _msgSendPort.send(message);
  }

  void close() {
    _msgSendPort.send(_CloseMsg());
  }

  Future<void> waitComplete() async {
    await _exitCompleter.future;
  }
}