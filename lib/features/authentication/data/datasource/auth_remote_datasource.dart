import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/features/authentication/data/models/auth_response_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource({required DioClient dioClient}) : _dioClient = dioClient;

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dioClient.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    final result = (data['data'] ?? data) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(result);
  }

  Future<AuthResponseModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _dioClient.post(
      Endpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final result = (data['data'] ?? data) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(result);
  }

  Future<void> logout() async {
    await _dioClient.post(Endpoints.logout);
  }

  Future<AuthResponseModel> refreshToken(String token) async {
    final response = await _dioClient.post(
      Endpoints.refreshToken,
      data: {'refreshToken': token},
    );
    final data = response.data as Map<String, dynamic>;
    final result = (data['data'] ?? data) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(result);
  }

  Future<void> forgotPassword(String email) async {
    await _dioClient.post(
      Endpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword(String token, String password) async {
    await _dioClient.post(
      Endpoints.resetPassword,
      data: {'token': token, 'password': password},
    );
  }
}
