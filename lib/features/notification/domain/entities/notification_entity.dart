import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String description; // maps to 'message' from backend
  final String type;
  final int? relatedId;
  final String createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.relatedId,
    required this.createdAt,
    required this.isRead,
  });

  NotificationEntity copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    int? relatedId,
    String? createdAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, description, type, relatedId, createdAt, isRead];
}
