import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/chat/data/models/message_model.dart';

/// STOMP-over-WebSocket client for real-time inbound chat messages.
///
/// Connects to `ws(s)://<backend>/ws`, authenticates the STOMP CONNECT frame
/// with the logged-in user's Bearer token, and subscribes to the per-user
/// queue `/user/queue/chat`. Each pushed message is decoded into a
/// [MessageModel] and emitted on [messages].
class ChatSocketClient {
  final AuthTokenStorage _tokenStorage;

  StompClient? _client;
  final StreamController<MessageModel> _controller =
      StreamController<MessageModel>.broadcast();

  ChatSocketClient(this._tokenStorage);

  Stream<MessageModel> get messages => _controller.stream;

  /// `http(s)://host` → `ws(s)://host/ws`.
  static String get _wsUrl =>
      '${ApiConstants.baseUrl.replaceFirst('http', 'ws')}/ws';

  /// Opens the socket if not already connected. Safe to call repeatedly.
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
        onWebSocketError: (dynamic e) => debugPrint('Chat WS error: $e'),
        onStompError: (StompFrame f) =>
            debugPrint('Chat STOMP error: ${f.body}'),
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame _) {
    _client?.subscribe(
      destination: '/user/queue/chat',
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          _controller.add(MessageModel.fromJson(json));
        } catch (e) {
          debugPrint('Chat WS parse error: $e');
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
