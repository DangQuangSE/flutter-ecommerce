import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatsLoaded extends ChatState {
  final List<ChatEntity> chats;

  const ChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

final class ChatRoomLoaded extends ChatState {
  final ChatEntity chat;
  final List<MessageEntity> messages;

  const ChatRoomLoaded({
    required this.chat,
    required this.messages,
  });

  @override
  List<Object?> get props => [chat, messages];
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
