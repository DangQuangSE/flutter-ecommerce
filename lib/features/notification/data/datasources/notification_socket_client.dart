import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/notification/data/models/notification_model.dart';

class NotificationSocketClient {
  final AuthTokenStorage _tokenStorage;

  StompClient? _client;
  final StreamController<NotificationModel> _controller =
      StreamController<NotificationModel>.broadcast();

  NotificationSocketClient(this._tokenStorage);

  Stream<NotificationModel> get notifications => _controller.stream;

  static String get _wsUrl =>
      '${ApiConstants.baseUrl.replaceFirst('http', 'ws')}/ws';

  void connect() {
    final token = _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return;
    if (_client != null && _client!.connected) return;

    _client?.deactivate();
    final headers = {'Authorization': 'Bearer $token'};
    _client = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: _onConnect,
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        reconnectDelay: const Duration(seconds: 5),
        onWebSocketError: (dynamic e) => debugPrint('Customer WS error: $e'),
        onStompError: (StompFrame f) =>
            debugPrint('Customer STOMP error: ${f.body}'),
      ),
    );
    _client!.activate();
  }

  int? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload);
      return data['uid'] as int?;
    } catch (e) {
      return null;
    }
  }

  void _onConnect(StompFrame _) {
    final token = _tokenStorage.getAccessToken();
    if (token == null) return;
    
    final userId = _getUserIdFromToken(token);
    if (userId == null) return;

    _client?.subscribe(
      destination: '/topic/user/$userId/notifications',
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _controller.add(NotificationModel.fromJson(json));
        } catch (e) {
          debugPrint('Customer WS parse error: $e');
        }
      },
    );
  }

  void disconnect() => _client?.deactivate();

  Future<void> dispose() async {
    _client?.deactivate();
    await _controller.close();
  }
}
