import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String? phone;

  const ProfileEntity({
    required this.userId,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.phone,
  });

  @override
  List<Object?> get props => [userId, displayName, email, avatarUrl, phone];
}
