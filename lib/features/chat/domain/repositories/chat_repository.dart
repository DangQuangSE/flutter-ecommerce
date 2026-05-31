import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/message_entity.dart';

abstract interface class ChatRepository {
  Future<Result<List<ChatEntity>>> getChats();
  Future<Result<List<MessageEntity>>> getMessages(String chatId);
  Future<Result<MessageEntity>> sendMessage(String chatId, String content);
  Stream<MessageEntity> get botReplyStream;
}
