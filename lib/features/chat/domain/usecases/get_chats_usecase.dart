import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatsUseCase {
  final ChatRepository _repository;

  const GetChatsUseCase(this._repository);

  Future<Result<List<ChatEntity>>> call() => _repository.getChats();
}
