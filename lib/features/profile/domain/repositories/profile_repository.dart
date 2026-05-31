import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/profile/domain/entities/profile_entity.dart';

abstract interface class ProfileRepository {
  Future<Result<ProfileEntity>> getProfile(String userId);
  Future<Result<void>> updateProfile(ProfileEntity profile);
}
