import 'package:equatable/equatable.dart';

/// The current user's profile. Maps to the backend `UserProfileResponse`
/// (`GET /api/profiles/me`). Only [firstName]/[lastName] and the avatar are
/// editable; the rest is read-only account/loyalty info.
class ProfileEntity extends Equatable {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String role;
  final String tier;
  final double totalSpending;
  final bool isActive;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.role = 'USER',
    this.tier = 'BRONZE',
    this.totalSpending = 0,
    this.isActive = true,
  });

  /// Full display name, falling back to the email when no name is set.
  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  ProfileEntity copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? role,
    String? tier,
    double? totalSpending,
    bool? isActive,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      tier: tier ?? this.tier,
      totalSpending: totalSpending ?? this.totalSpending,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        avatar,
        role,
        tier,
        totalSpending,
        isActive,
      ];
}
