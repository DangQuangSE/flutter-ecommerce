import 'dart:async';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_ecommerce/features/chat/data/models/chat_model.dart';
import 'package:flutter_ecommerce/features/chat/data/models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  // In-memory lists to simulate mutable backend database
  final List<ChatEntity> _chats = List.from(ChatModel.mockChats);
  final Map<String, List<MessageEntity>> _messagesMap = {};

  ChatRepositoryImpl() {
    // Pre-populate message histories
    for (final chat in _chats) {
      _messagesMap[chat.id] = List.from(MessageModel.getMockMessages(chat.id));
    }
  }

  // A controller stream to alert the Cubit of new incoming bot replies!
  final StreamController<MessageEntity> _botReplyStreamController =
      StreamController<MessageEntity>.broadcast();

  Stream<MessageEntity> get botReplyStream => _botReplyStreamController.stream;

  @override
  Future<Result<List<ChatEntity>>> getChats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success(List.from(_chats));
  }

  @override
  Future<Result<List<MessageEntity>>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Clear unread count for this chat room when opened
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
    }

    if (!_messagesMap.containsKey(chatId)) {
      _messagesMap[chatId] = [];
    }
    return Success(List.from(_messagesMap[chatId]!));
  }

  @override
  Future<Result<MessageEntity>> sendMessage(String chatId, String content) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final newMessage = MessageEntity(
      id: 'msg-user-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      content: content,
      timestamp: _getCurrentTimeFormatted(),
      isMe: true,
    );

    // Save message locally
    if (!_messagesMap.containsKey(chatId)) {
      _messagesMap[chatId] = [];
    }
    _messagesMap[chatId]!.add(newMessage);

    // Update last message in the thread
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(
        lastMessage: content,
        lastMessageTime: newMessage.timestamp,
        unreadCount: 0,
      );
    }

    // Trigger simulated support bot response after 1.2 seconds for realistic demo!
    _triggerBotResponse(chatId, content);

    return Success(newMessage);
  }

  void _triggerBotResponse(String chatId, String userMessage) {
    Timer(const Duration(milliseconds: 1200), () {
      String replyText = '';
      bool isSystemText = false;

      final lowerMsg = userMessage.toLowerCase();
      if (lowerMsg.contains('áo') || lowerMsg.contains('đặt may') || lowerMsg.contains('thiết kế')) {
        replyText = 'SPORT PRO đã nhận được yêu cầu của bạn. Nhân viên kỹ thuật thiết kế sẽ phác thảo bản vẽ chi tiết gửi bạn duyệt ngay nhé!';
        isSystemText = true;
      } else if (lowerMsg.contains('giá') || lowerMsg.contains('bao nhiêu')) {
        replyText = 'Hiện tại mẫu áo này đang có giá ưu đãi là 180.000đ/bộ khi đặt trên 10 bộ ạ. Bạn có muốn chọn size không?';
      } else if (lowerMsg.contains('địa chỉ') || lowerMsg.contains('cửa hàng')) {
        replyText = 'Cửa hàng Sport Pro của chúng em có cơ sở tại 123 Đường Láng, Đống Đa, Hà Nội. Rất mong được đón tiếp anh!';
      } else {
        replyText = 'Cảm ơn bạn đã nhắn tin. SPORT PRO rất hân hạnh được hỗ trợ bạn. Chúng tôi sẽ phản hồi yêu cầu chi tiết trong chốc lát nhé!';
      }

      final botMessage = MessageEntity(
        id: 'msg-bot-${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'other',
        content: replyText,
        timestamp: _getCurrentTimeFormatted(),
        isMe: false,
        isSystem: isSystemText,
      );

      // Save to chat history
      if (_messagesMap.containsKey(chatId)) {
        _messagesMap[chatId]!.add(botMessage);
      }

      // Update thread last message
      final index = _chats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(
          lastMessage: replyText,
          lastMessageTime: botMessage.timestamp,
          unreadCount: 0,
        );
      }

      // Emit bot reply to the listener stream
      _botReplyStreamController.add(botMessage);
    });
  }

  String _getCurrentTimeFormatted() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
