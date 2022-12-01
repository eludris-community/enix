import 'package:enix/enix.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  final enix = Enix(
    name: "enix-bot",
    gatewayURL: 'wss://ws.eludris.gay',
    restURL: 'https://api.eludris.gay',
  );
  Logger.root.level = Level.ALL;
  enix.addLogging();

  enix.gateway.onMessageCreate.listen((message) async {
    if (message.content == "!shing") {
      print("got message");
      await enix.createMessage(content: "Pong!");
    }
  });

  await enix.connect();
}
