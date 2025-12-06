import 'package:sfo_isolate/sfo_isolate.dart';

void main() async {
  final isolate = await SfoIsolate.create((msg) async {
    print("$msg");
  });

  isolate.send(1);
  isolate.send(2);
  isolate.close();
  await isolate.waitComplete();
  print("complete");
}
