import 'dart:io';

import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/profile/domain/entities/profile_entity.dart';

abstract interface class ProfileRepository {
  /// `GET /api/profiles/me` — the current user's profile.
  Future<Result<ProfileEntity>> getMyProfile();

  /// `PUT /api/profiles/me` — updates the editable name fields.
  Future<Result<ProfileEntity>> updateProfile({
    required String firstName,
    required String lastName,
  });

  /// `POST /api/profiles/me/avatar` — uploads a new avatar image.
  Future<Result<ProfileEntity>> updateAvatar(File image);
}
