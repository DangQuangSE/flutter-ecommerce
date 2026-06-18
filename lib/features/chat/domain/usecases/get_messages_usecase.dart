import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository _repository;

  const GetMessagesUseCase(this._repository);

  Future<Result<List<MessageEntity>>> call(String chatId) =>
      _repository.getMessages(chatId);
}
