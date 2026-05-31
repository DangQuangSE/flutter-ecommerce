import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.isMe,
    super.imageUrl,
    super.isSystem,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
      isMe: json['isMe'] as bool,
      imageUrl: json['imageUrl'] as String?,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
      'isMe': isMe,
      'imageUrl': imageUrl,
      'isSystem': isSystem,
    };
  }

  static List<MessageModel> getMockMessages(String chatId) {
    if (chatId == 'chat-support' || chatId == 'chat-designer') {
      return [
        const MessageModel(
          id: 'msg-1',
          senderId: 'other',
          content: 'Chào shop, mình muốn đặt may 10 bộ áo bóng đá cho đội.',
          timestamp: '09:42',
          isMe: false,
        ),
        const MessageModel(
          id: 'msg-2',
          senderId: 'me',
          content: 'Chào anh A, SPORT PRO rất vui được hỗ trợ. Anh có bản thiết kế sẵn chưa hay muốn tham khảo mẫu của bên em ạ?',
          timestamp: '09:45',
          isMe: true,
        ),
        const MessageModel(
          id: 'msg-3',
          senderId: 'other',
          content: 'Mình có mẫu nháp này. Màu đỏ cam kết hợp viền đen, logo đặt ngực trái nhé.',
          timestamp: '09:50',
          isMe: false,
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7QUqexWT8UObnocEW75IOV54pAgFrmMun4rvJuQhpsaEwEiB6J8a4WUnYc5qH3PyrJsdYr6jIVtINUJl7V-OlWpzFcChekbfSX-LZUIUlwMDmNGa6RbBZRyk-675LI0dRv7IUd_qeHLWtr9LKi-E6fwFCOuCbve308GWI6KDc4pdd5doLKTC0mmt_g8Hte_HAaXme3zp7_XFJ3tW-jTfXpkIbhZH0QpnqEOxjJzRHHsGKUdNxi5BNqy3zWEhPAeP2PEdFT5InfZA',
        ),
        const MessageModel(
          id: 'msg-4',
          senderId: 'me',
          content: 'Tuyệt vời. Đội ngũ thiết kế sẽ phác thảo bản 3D chi tiết dựa trên mẫu này và gửi anh duyệt trong vòng 2h tới nhé.',
          timestamp: '09:55',
          isMe: true,
          isSystem: true, // We can style this bubble specifically like the designed system bubble with design_services icon
        ),
      ];
    } else if (chatId == 'chat-shipping') {
      return [
        const MessageModel(
          id: 'msg-ship-1',
          senderId: 'me',
          content: 'Chào shipper, khi nào đơn hàng #SP2024-8839 của mình được giao vậy ạ?',
          timestamp: 'Hôm qua, 14:15',
          isMe: true,
        ),
        const MessageModel(
          id: 'msg-ship-2',
          senderId: 'other',
          content: 'Chào anh, đơn hàng của anh đã cập bến trạm phân phối Hà Nội lúc 17h. Dự kiến sẽ được giao cho anh vào sáng mai nhé.',
          timestamp: 'Hôm qua, 17:30',
          isMe: false,
        ),
      ];
    }
    return [
      const MessageModel(
        id: 'msg-default-1',
        senderId: 'other',
        content: 'Chào bạn, chúng tôi có thể giúp gì cho bạn hôm nay?',
        timestamp: '10:00',
        isMe: false,
      ),
    ];
  }
}
