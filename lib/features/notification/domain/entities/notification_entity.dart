import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // order, promo, product, system
  final String createdAt; // e.g. "10 phút trước", "2 giờ trước"
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? createdAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, description, type, createdAt, isRead];
}
