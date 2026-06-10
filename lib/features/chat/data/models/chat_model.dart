import '../../domain/entities/chat_entity.dart';

/// Maps the backend `ConversationResponse` to a [ChatEntity].
class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.senderName,
    required super.senderAvatar,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.unreadCount,
    required super.isOnline,
    super.tag,
    super.associatedProductImage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim();
    final avatar = (json['avatar'] as String?)?.trim();
    final displayName = (name == null || name.isEmpty) ? 'Hỗ trợ Sport Pro' : name;
    return ChatModel(
      id: json['id'].toString(),
      senderName: displayName,
      senderAvatar:
          (avatar == null || avatar.isEmpty) ? _fallbackAvatar(displayName) : avatar,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: formatTimestamp(json['lastMessageAt'] as String?),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isOnline: json['online'] as bool? ?? false,
      tag: json['tag'] as String?,
      associatedProductImage: json['associatedProductImage'] as String?,
    );
  }

  static String _fallbackAvatar(String name) =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=1A73E8&color=fff';

  /// Formats a backend ISO `LocalDateTime` into a short label for the chat list
  /// (HH:mm today, "Hôm qua", else dd/MM). Shared by [ChatModel]/MessageModel.
  static String formatTimestamp(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final isToday =
        local.year == now.year && local.month == now.month && local.day == now.day;
    if (isToday) return '${two(local.hour)}:${two(local.minute)}';
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;
    if (isYesterday) return 'Hôm qua';
    return '${two(local.day)}/${two(local.month)}';
  }
}
