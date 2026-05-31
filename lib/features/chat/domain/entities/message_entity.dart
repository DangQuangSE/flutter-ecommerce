import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String content;
  final String timestamp;
  final bool isMe;
  final String? imageUrl; // For optional image attachments
  final bool isSystem;   // For status alerts or design status updates

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
    this.isSystem = false,
  });

  @override
  List<Object?> get props => [id, senderId, content, timestamp, isMe, imageUrl, isSystem];
}
