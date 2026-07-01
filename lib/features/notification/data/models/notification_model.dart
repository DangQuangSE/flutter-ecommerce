import 'package:flutter_ecommerce/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    super.relatedId,
    required super.createdAt,
    required super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['message'] as String,
        type: json['type'] as String,
        relatedId: json['relatedId'] as int?,
        createdAt: json['createdAt'] is List 
            ? '${json['createdAt'][0]}-${json['createdAt'][1].toString().padLeft(2, '0')}-${json['createdAt'][2].toString().padLeft(2, '0')}T${json['createdAt'].length > 3 ? json['createdAt'][3].toString().padLeft(2, '0') : '00'}:${json['createdAt'].length > 4 ? json['createdAt'][4].toString().padLeft(2, '0') : '00'}'
            : json['createdAt']?.toString() ?? '',
        isRead: json['isRead'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': description,
        'type': type,
        'relatedId': relatedId,
        'createdAt': createdAt,
        'isRead': isRead,
      };
}
