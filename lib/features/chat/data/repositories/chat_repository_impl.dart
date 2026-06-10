import 'dart:async';

import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_socket_client.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatSocketClient _socketClient;

  late final StreamSubscription<MessageEntity> _socketSub;

  ChatRepositoryImpl(this._remoteDataSource, this._socketClient) {
    // Pipe real-time WebSocket messages into the stream the cubit listens to.
    _socketSub = _socketClient.messages.listen(_incoming.add);
  }

  /// Real-time inbound messages (Phase 2: fed by the WebSocket socket client).
  /// Named `botReplyStream` to satisfy the existing [ChatRepository] contract.
  final StreamController<MessageEntity> _incoming =
      StreamController<MessageEntity>.broadcast();

  @override
  Stream<MessageEntity> get botReplyStream => _incoming.stream;

  @override
  Future<Result<List<ChatEntity>>> getChats() {
    _socketClient.connect();
    return _guard(() => _remoteDataSource.getConversations());
  }

  @override
  Future<Result<List<MessageEntity>>> getMessages(String chatId) {
    _socketClient.connect();
    return _guard(() => _remoteDataSource.getMessages(chatId));
  }

  @override
  Future<Result<MessageEntity>> sendMessage(String chatId, String content) =>
      _guard(() => _remoteDataSource.sendMessage(chatId, content));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on UnauthorisedException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on ParseException catch (e) {
      return ResultFailure(ParseFailure(e.message));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  Future<void> dispose() async {
    await _socketSub.cancel();
    await _socketClient.dispose();
    await _incoming.close();
  }
}
