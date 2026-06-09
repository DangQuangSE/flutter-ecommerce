import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/message_entity.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetChatsUseCase _getChatsUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final ChatRepository _repository;

  StreamSubscription<MessageEntity>? _botReplySubscription;
  List<ChatEntity> _cachedChats = [];

  ChatCubit({
    required GetChatsUseCase getChatsUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required ChatRepository repository,
  })  : _getChatsUseCase = getChatsUseCase,
        _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _repository = repository,
        super(const ChatInitial()) {
    // Listen to real-time inbound messages (WebSocket) app-wide.
    _botReplySubscription = _repository.botReplyStream.listen(_onIncomingMessage);
  }

  int get totalUnreadMessages {
    return _cachedChats.fold(0, (sum, chat) => sum + chat.unreadCount);
  }

  Future<void> loadChats() async {
    emit(const ChatLoading());
    final result = await _getChatsUseCase();
    switch (result) {
      case Success(:final data):
        // Reify as List<ChatEntity>: the datasource returns ChatModel instances,
        // so a plain assignment leaves the runtime type as List<ChatModel>, which
        // breaks firstWhere(orElse: () => ChatEntity(...)) below.
        _cachedChats = List<ChatEntity>.from(data);
        emit(ChatsLoaded(List<ChatEntity>.from(data)));
      case ResultFailure(:final failure):
        emit(ChatError(failure.message));
    }
  }

  Future<void> loadChatRoom(String chatId) async {
    emit(const ChatLoading());
    
    // First, find the chat room metadata
    if (_cachedChats.isEmpty) {
      final chatsResult = await _getChatsUseCase();
      if (chatsResult is Success<List<ChatEntity>>) {
        _cachedChats = List<ChatEntity>.from(chatsResult.data);
      }
    }
    
    final chat = _cachedChats.firstWhere(
      (c) => c.id == chatId,
      orElse: () => ChatEntity(
        id: chatId,
        senderName: 'Hỗ trợ khách hàng',
        senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuApsVdGBPiD4UfQ4dq1G7LbkH4_du0P8atXrOzXMPxXIPdU9Evf2fHBiv7n7rkz7-2QwAtRh9jhucCQIhGfbTu8TG-hNBBUayau1uU9dh_oWUZ3jDss2SKaH07vLDY0FuMAutm_7fkiDrxd54uP7jBTk4wMGALX7txCZ23xCJ5rodhCMHV2xtkumkyv6Ln5L36hTGU5DuLjTK5VgukX5QbiLdM1cTUlixcCjb3dHVfOIvJn9iU91V3MsOjneh2RJEq60HzZhkyXIPs',
        lastMessage: '',
        lastMessageTime: '',
        unreadCount: 0,
        isOnline: true,
      ),
    );

    final result = await _getMessagesUseCase(chatId);
    switch (result) {
      case Success(:final data):
        // Update the cached chat room unread count to 0 in memory
        final index = _cachedChats.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          _cachedChats[index] = _cachedChats[index].copyWith(unreadCount: 0);
        }
        emit(ChatRoomLoaded(chat: chat, messages: List.from(data)));
      case ResultFailure(:final failure):
        emit(ChatError(failure.message));
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    if (content.trim().isEmpty) return;

    final currentState = state;
    if (currentState is ChatRoomLoaded) {
      // Optimistically add user's message to active chat bubble list
      final tempUserMsg = MessageEntity(
        id: 'msg-user-temp-${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        content: content,
        timestamp: _getCurrentTimeFormatted(),
        isMe: true,
      );

      final updatedMessages = List<MessageEntity>.from(currentState.messages)..add(tempUserMsg);
      emit(ChatRoomLoaded(chat: currentState.chat, messages: updatedMessages));

      // Call domain layer UseCase
      final result = await _sendMessageUseCase(chatId, content);
      switch (result) {
        case Success(:final data):
          // Replace temp message with actual saved message
          final finalMessages = List<MessageEntity>.from(currentState.messages);
          final index = finalMessages.indexWhere((m) => m.id.startsWith('msg-user-temp-'));
          if (index != -1) {
            finalMessages[index] = data;
          } else {
            finalMessages.add(data);
          }
          
          // Update last message in the cached thread
          final threadIndex = _cachedChats.indexWhere((c) => c.id == chatId);
          if (threadIndex != -1) {
            _cachedChats[threadIndex] = _cachedChats[threadIndex].copyWith(
              lastMessage: content,
              lastMessageTime: data.timestamp,
              unreadCount: 0,
            );
          }

          emit(ChatRoomLoaded(chat: currentState.chat.copyWith(
            lastMessage: content,
            lastMessageTime: data.timestamp,
          ), messages: finalMessages));
          
        case ResultFailure(:final failure):
          // If sending fails, we can either re-emit the error state or show a message
          emit(ChatError(failure.message));
      }
    }
  }

  /// Handles a real-time inbound message pushed over WebSocket. Routes it to
  /// the right thread by [MessageEntity.conversationId].
  void _onIncomingMessage(MessageEntity message) {
    final conversationId = message.conversationId;
    if (conversationId == null) return;

    final currentState = state;
    final isViewingRoom =
        currentState is ChatRoomLoaded && currentState.chat.id == conversationId;

    // 1. Update the cached inbox entry (last message + unread badge).
    final threadIndex = _cachedChats.indexWhere((c) => c.id == conversationId);
    if (threadIndex != -1) {
      final target = _cachedChats[threadIndex];
      _cachedChats[threadIndex] = target.copyWith(
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
        unreadCount: isViewingRoom ? 0 : target.unreadCount + 1,
      );
    }

    // 2. Reflect the change in the current view.
    if (isViewingRoom) {
      final updatedMessages =
          List<MessageEntity>.from(currentState.messages)..add(message);
      emit(ChatRoomLoaded(
        chat: currentState.chat.copyWith(
          lastMessage: message.content,
          lastMessageTime: message.timestamp,
        ),
        messages: updatedMessages,
      ));
    } else if (currentState is ChatsLoaded) {
      emit(ChatsLoaded(List.from(_cachedChats)));
    }
  }

  String _getCurrentTimeFormatted() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Future<void> close() {
    _botReplySubscription?.cancel();
    return super.close();
  }
}
