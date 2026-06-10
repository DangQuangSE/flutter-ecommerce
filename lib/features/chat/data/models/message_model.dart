import '../../domain/entities/message_entity.dart';
import 'chat_model.dart';

/// Maps the backend `MessageResponse` to a [MessageEntity]. `isMe` comes from
/// the backend `mine` flag (computed relative to the requesting user).
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.isMe,
    super.imageUrl,
    super.isSystem,
    super.conversationId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      senderId: json['senderId']?.toString() ?? '',
      content: json['content'] as String? ?? '',
      timestamp: ChatModel.formatTimestamp(json['createdAt'] as String?),
      isMe: json['mine'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      isSystem: json['system'] as bool? ?? false,
      conversationId: json['conversationId']?.toString(),
    );
  }
}
