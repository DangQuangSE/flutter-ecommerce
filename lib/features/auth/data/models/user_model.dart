import 'package:flutter_ecommerce/features/auth/data/models/auth_me_model.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.avatarUrl,
    required super.createdAt,
  });

  factory UserModel.fromAuthMe(AuthMeModel me) {
    final email = me.email.trim().toLowerCase();
    final localPart = email.split('@').first;
    return UserModel(
      id: email,
      email: email,
      name: localPart.isEmpty ? email : localPart,
      role: me.role,
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'USER',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };

  static UserModel get mock => UserModel(
        id: 'user-001',
        email: 'demo@example.com',
        name: 'demo',
        role: 'USER',
        createdAt: DateTime(2024, 1, 1),
      );
}
