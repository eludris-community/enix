import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:enix/src/abc.dart';
import 'package:enix/src/models/message.dart';
import 'package:enix/src/rest.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Gateway');

class Gateway implements Disposable {
  String? _url;
  final Rest _rest;

  WebSocket? _ws;
  final List<StreamSubscription?> _subs = [];

  final _onMessageCreate = StreamController<Message>.broadcast();
  final _onConnected = StreamController<void>.broadcast();

  int _reconnectTimeout = 5;

  Gateway({String? url, required Rest rest})
      : _url = url,
        _rest = rest;
  Stream<void> get onConnected => _onConnected.stream;

  Stream<Message> get onMessageCreate => _onMessageCreate.stream;

  Future<void> connect() async {
    if (_url == null) {
      final info = await _rest.getInstanceInfo();
      _url = info.pandemoniumUrl;
      _logger.info('Got gateway URL over REST: $_url');
    }

    _ws = await WebSocket.connect(_url!);
    _reconnectTimeout = 5;

    _ws!.done.then((_) async {
      if (_ws!.closeCode == null) {
        return;
      }
      _logger.warning('Gateway closed with code ${_ws!.closeCode} and reason '
          '"${_ws!.closeReason}');
      _logger.info('Reconnecting in $_reconnectTimeout seconds.');

      await Future.delayed(Duration(seconds: _reconnectTimeout));

      _reconnectTimeout *= 2;

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
