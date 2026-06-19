import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  /// Loads the current user's profile. Skips re-loading if already loaded.
  Future<void> loadProfile({bool force = false}) async {
    if (!force && state is ProfileLoaded) return;
    emit(const ProfileLoading());
    final result = await _repository.getMyProfile();
    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
      case ResultFailure(:final failure):
        emit(ProfileError(failure.message));
    }
  }

  /// Updates the name fields. Returns `null` on success, else an error message.
  Future<String?> updateName({
    required String firstName,
    required String lastName,
  }) async {
    final result = await _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
    );
    return _applyResult(result);
  }

  /// Uploads a new avatar. Returns `null` on success, else an error message.
  Future<String?> updateAvatar(File image) async {
    final result = await _repository.updateAvatar(image);
    return _applyResult(result);
  }

  String? _applyResult(Result<ProfileEntity> result) {
    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
        return null;
      case ResultFailure(:final failure):
        return failure.message;
    }
  }
}
