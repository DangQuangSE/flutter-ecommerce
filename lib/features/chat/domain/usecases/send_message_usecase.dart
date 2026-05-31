import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  const SendMessageUseCase(this._repository);

  Future<Result<MessageEntity>> call(String chatId, String content) =>
      _repository.sendMessage(chatId, content);
}
