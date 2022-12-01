import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:enix/src/abc.dart';
import 'package:enix/src/models/message.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Gateway');

class Gateway implements Disposable {
  final String _url;

  WebSocket? _ws;
  final List<StreamSubscription?> _subs = [];

  final _onMessageCreate = StreamController<Message>();
  final _onConnected = StreamController<void>();

  Gateway({required String url}) : _url = url;
  Stream<void> get onConnected => _onConnected.stream;

  Stream<Message> get onMessageCreate => _onMessageCreate.stream;

  Future<void> connect() async {
    _ws = await WebSocket.connect(_url);
    _ws!.done.then((_) async {
      if (_ws!.closeCode == null) {
        return;
      }
      _logger.warning('Gateway closed with code ${_ws!.closeCode} and reason '
          '"${_ws!.closeReason}');
      _logger.info('Reconnecting in 5 seconds.');
      await Future.delayed(Duration(seconds: 5));
      await dispose();
      await connect();
    });
    _logger.info('Connected to gateway at $_url');

    _onConnected.add(null);
    _pings(1);
    _subs.add(Stream.periodic(Duration(seconds: 45)).listen(_pings));
    _subs.add(_ws?.listen(_handler));
  }

  @override
  Future<void> dispose() async {
    _logger.info('Disconnecting from gateway at $_url');
    await _ws?.close();
    for (final sub in _subs) {
      await sub?.cancel();
    }
  }

  void _handler(dynamic message) {
    _logger.fine('< $message');
    final data = jsonDecode(message);

    final op = data['op'] as String;
    switch (op) {
      case "MESSAGE_CREATE":
        _onMessageCreate.add(Message.fromJson(data['d']));
        break;
    }
  }

  void _pings(event) {
    if (_ws != null && _ws!.readyState == WebSocket.open) {
      final d = jsonEncode({'op': 'PING'});
      _logger.fine('> $d');
      _ws!.add(d);
    }
  }
}
