import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Rest');

class Rest {
  final String _baseURL;
  final Client _client;

  Rest({required baseURL})
      : _baseURL = baseURL,
        _client = Client();

  Future<void> createMessage(
      {required String author, required String content}) async {
    final d = jsonEncode({'author': author, 'content': content});

    _logger.fine('POST $_baseURL/messages with $d');

    await _client.post(Uri.parse('$_baseURL/messages'), body: d);
  }
}
