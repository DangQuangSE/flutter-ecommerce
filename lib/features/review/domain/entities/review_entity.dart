import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final List<String> images;
  final String? replyComment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.images = const [],
    this.replyComment,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, userName, userAvatar, rating, comment, images, replyComment, createdAt];
}
