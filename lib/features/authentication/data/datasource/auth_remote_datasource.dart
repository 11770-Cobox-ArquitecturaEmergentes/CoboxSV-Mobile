import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/authentication/data/models/auth_response_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource({required DioClient dioClient}) : _dioClient = dioClient;

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dioClient.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final response = await _dioClient.get('${Endpoints.users}/$userId');
    return response.data as Map<String, dynamic>?;
  }

  Future<AuthResponseModel> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await _dioClient.post(
      Endpoints.register,
      data: {
        'firstName': _firstName(name),
        'lastName': _lastName(name),
        'email': email,
        'password': password,
        'phone': phone,
        'roles': const ['ROLE_DRIVER'],
      },
    );
    try {
      return await login(email, password);
    } on AppException catch (error) {
      if (error.statusCode == 401) {
        throw const AppException(
          'La cuenta fue creada, pero el inicio de sesion automatico fallo. Inicia sesion manualmente.',
        );
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    return;
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
    throw const AppException(
      'La recuperación de contraseña no está disponible en el backend actual.',
    );
  }

  Future<void> resetPassword(String token, String password) async {
    throw const AppException(
      'El restablecimiento de contraseña no está disponible en el backend actual.',
    );
  }

  String _firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : fullName.trim();
  }

  String _lastName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return 'Usuario';
    return parts.skip(1).join(' ');
  }
}
