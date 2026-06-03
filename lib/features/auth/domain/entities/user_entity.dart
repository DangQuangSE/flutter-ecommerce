import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final String? role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    this.role,
  });

  bool get isAdmin => email.toLowerCase().contains('admin');

  @override
  List<Object?> get props => [id, email, name, avatarUrl, createdAt, role];
}
