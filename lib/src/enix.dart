import 'dart:io';

import 'package:enix/src/abc.dart';
import 'package:enix/src/gateway.dart';
import 'package:enix/src/rest.dart';
import 'package:logging/logging.dart';

class Enix implements Disposable {
  static const String version = '0.1.0';
  final String name;

  final Gateway gateway;
  final Rest _rest;

  Enix(
      {required this.name, required String gatewayURL, required String restURL})
      : gateway = Gateway(url: gatewayURL),
        _rest = Rest(baseURL: restURL);

  Future<void> connect() async {
    ProcessSignal.sigint.watch().listen((_) async {
      await dispose();
      exit(0);
    });

    await gateway.connect();
  }

  Future<void> createMessage({required String content}) async {
    await _rest.createMessage(author: name, content: content);
  }

  @override
  Future<void> dispose() async {
    await gateway.dispose();
  }

  void addLogging() {
    Logger.root.onRecord.listen((LogRecord rec) {
      print(
          '[${rec.time}] [${rec.level.name}] [${rec.loggerName}] ${rec.message}');
    });
  }
}
