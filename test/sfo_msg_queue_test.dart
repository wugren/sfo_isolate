import 'package:sfo_isolate/sfo_msg_queue.dart';

void main() async {
  final isolate = await SfoMsgQueue.create((msg) async {
    await Future.delayed(Duration(seconds: 1));
    print("$msg");
  });

  isolate.send(1);
  isolate.send(2);
  isolate.close();
  await isolate.waitComplete();
  print("complete");
}
