import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_notification_model.dart';

class AdminSocketClient {
  final AuthTokenStorage _tokenStorage;

  StompClient? _client;
  final StreamController<AdminNotificationModel> _controller =
      StreamController<AdminNotificationModel>.broadcast();

  AdminSocketClient(this._tokenStorage);

  Stream<AdminNotificationModel> get notifications => _controller.stream;

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
        onWebSocketError: (dynamic e) => debugPrint('Admin WS error: $e'),
        onStompError: (StompFrame f) =>
            debugPrint('Admin STOMP error: ${f.body}'),
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame _) {
    _client?.subscribe(
      destination: '/topic/admin/notifications',
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _controller.add(AdminNotificationModel.fromJson(json));
        } catch (e) {
          debugPrint('Admin WS parse error: $e');
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
