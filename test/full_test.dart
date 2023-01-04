import 'package:enix/enix.dart';
import 'package:test/test.dart';

void main() {
  final enix = Enix(
    name: "test-bot",
    restURL: "https://api-eludris.teaishealthy.me",
    gatewayURL: "wss://ws-eludris.teaishealthy.me",
  );

  enix.addLogging();

  test("can send message", () async {
    await enix.createMessage(content: "Hello, world!");
  });

  test("can dispose", () async {
    await enix.dispose();
  });

  test("can connect and receive messages", () async {
    await enix.connect();

    final s = enix.gateway.onMessageCreate
        .timeout(Duration(seconds: 5))
        .listen((msg) {
      print(msg);

      final json = msg.toJson();
      expect(json["content"], "Hello, world!");
      expect(json["author"], "test-bot");

      expect(msg.content, "Hello, world!");
      expect(msg.author, "test-bot");
    });

    await enix.createMessage(content: "Hello, world!");

    await s.cancel();
  });
}
