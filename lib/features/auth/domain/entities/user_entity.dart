import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  @override
  List<Object?> get props => [id, email, name, role, avatarUrl, createdAt];
}
