import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/profile/data/models/profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getMyProfile();
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
  });
  Future<ProfileModel> updateAvatar(File image);
}

/// Talks to `/api/profiles/me` over the shared [DioClient] (Bearer token
/// attached for the logged-in user).
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  const ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ProfileModel> getMyProfile() async {
    final response = await _dioClient.dio
        .get<Map<String, dynamic>>(ApiConstants.profileMe);
    return _parse(response.data);
  }

  @override
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      ApiConstants.profileMe,
      data: ProfileModel.updateBody(firstName: firstName, lastName: lastName),
    );
    return _parse(response.data);
  }

  @override
  Future<ProfileModel> updateAvatar(File image) async {
    final fileName = image.path.split('/').last;
    final ext = fileName.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
        contentType: MediaType.parse(mime),
      ),
    });
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.profileAvatar,
      data: formData,
    );
    return _parse(response.data);
  }

  ProfileModel _parse(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Phản hồi hồ sơ không hợp lệ');
    }
    return ProfileModel.fromJson(data);
  }
}
