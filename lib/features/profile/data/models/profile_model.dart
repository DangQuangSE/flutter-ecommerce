import 'package:flutter_ecommerce/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.avatar,
    super.role,
    super.tier,
    super.totalSpending,
    super.isActive,
  });

  /// Parses a backend `UserProfileResponse`.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'USER',
      tier: json['tier'] as String? ?? 'BRONZE',
      totalSpending: _toDouble(json['totalSpending']) ?? 0,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
    );
  }

  /// Request body for `PUT /api/profiles/me`.
  static Map<String, dynamic> updateBody({
    required String firstName,
    required String lastName,
  }) =>
      {'firstName': firstName, 'lastName': lastName};

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
