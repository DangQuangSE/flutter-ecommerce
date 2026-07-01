import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    super.productId,
    super.productName,
    required super.userName,
    super.userAvatar,
    required super.rating,
    required super.comment,
    super.images = const [],
    super.replyComment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: _intFromJson(json['id']),
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? '',
      userName: json['userName'] as String? ?? AppStrings.anonymousReviewer,
      userAvatar: json['userAvatar'] as String?,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      replyComment: json['replyComment'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']),
    );
  }

  static int _intFromJson(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is List<dynamic> && value.length >= 3) {
      return DateTime(
        _intFromJson(value[0]),
        _intFromJson(value[1]),
        _intFromJson(value[2]),
        value.length > 3 ? _intFromJson(value[3]) : 0,
        value.length > 4 ? _intFromJson(value[4]) : 0,
        value.length > 5 ? _intFromJson(value[5]) : 0,
      );
    }
    return DateTime.now();
  }
}
