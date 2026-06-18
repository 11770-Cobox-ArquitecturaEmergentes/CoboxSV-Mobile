import 'dart:io';

import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/profile/data/models/profile_model.dart';

class ProfileRemoteDataSource {
  final DioClient _client;

  ProfileRemoteDataSource(this._client);

  Future<ProfileModel> getProfile() async {
    final response = await _client.get(Endpoints.profile);
    final data = response.data as Map<String, dynamic>?;
    if (data == null || data['data'] == null) {
      throw ServerException('Invalid profile response');
    }
    return ProfileModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put(
      Endpoints.updateProfile,
      data: data,
    );
    final responseData = response.data as Map<String, dynamic>?;
    if (responseData == null || responseData['data'] == null) {
      throw ServerException('Invalid update profile response');
    }
    return ProfileModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<String> uploadPhoto(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw const AppException('File not found');
    }
    final response = await _client.upload(
      Endpoints.uploadPhoto,
      files: {'photo': file},
    );
    final data = response.data as Map<String, dynamic>?;
    if (data == null || data['data'] == null || data['data']['url'] == null) {
      throw ServerException('Invalid upload photo response');
    }
    return data['data']['url'] as String;
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _client.post(
      Endpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
    );
  }
}
