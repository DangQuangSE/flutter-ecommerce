import 'package:flutter_ecommerce/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.createdAt,
    required super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: json['type'] as String,
        createdAt: json['createdAt'] as String,
        isRead: json['isRead'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'createdAt': createdAt,
        'isRead': isRead,
      };

  static List<NotificationModel> get mockList => [
        const NotificationModel(
          id: 'notif-001',
          title: 'Đơn hàng #SP2024-8839 đã được xác nhận',
          description:
              'Đơn hàng của bạn đang được đóng gói và sẽ sớm được giao cho đơn vị vận chuyển. Cảm ơn bạn đã mua sắm tại Velocity Pro.',
          type: 'order',
          createdAt: '10 phút trước',
          isRead: false,
        ),
        const NotificationModel(
          id: 'notif-002',
          title: 'Mã giảm giá 50k dành riêng cho bạn',
          description:
              'Mã FLASH50K đã được thêm vào ví voucher của bạn. Áp dụng cho đơn hàng từ 500k. Hết hạn trong 24h.',
          type: 'promo',
          createdAt: '2 giờ trước',
          isRead: false,
        ),
        const NotificationModel(
          id: 'notif-003',
          title: 'Hàng mới về: Áo khoác TechKnit Hoodie',
          description:
              'Đỉnh cao công nghệ dệt kim đã có mặt. Nhẹ nhàng, thoáng khí và sẵn sàng cho mọi buổi tập. Mua ngay!',
          type: 'product',
          createdAt: 'Hôm qua, 14:30',
          isRead: true,
        ),
        const NotificationModel(
          id: 'notif-004',
          title: 'Cập nhật hệ thống thành công',
          description: 'Ứng dụng đã được nâng cấp để cải thiện hiệu năng.',
          type: 'system',
          createdAt: '2 ngày trước',
          isRead: true,
        ),
      ];
}
