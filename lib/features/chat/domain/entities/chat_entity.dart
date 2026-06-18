import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final String senderName;
  final String senderAvatar;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? tag; // e.g., 'Shop', 'Hỗ trợ', 'Đơn hàng'
  final String?
      associatedProductImage; // associated product photo for e-commerce context

  const ChatEntity({
    required this.id,
    required this.senderName,
    required this.senderAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    this.tag,
    this.associatedProductImage,
  });

  ChatEntity copyWith({
    String? id,
    String? senderName,
    String? senderAvatar,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    String? tag,
    String? associatedProductImage,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      tag: tag ?? this.tag,
      associatedProductImage:
          associatedProductImage ?? this.associatedProductImage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderName,
        senderAvatar,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isOnline,
        tag,
        associatedProductImage,
      ];
}
