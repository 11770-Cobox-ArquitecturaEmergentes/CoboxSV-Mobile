import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:cobox_sv_mobile/core/api/auth0_config.dart';
import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/authentication/data/models/auth_response_model.dart';
import 'package:cobox_sv_mobile/shared/models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;
  final Dio _auth0Dio;

  AuthRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient,
        _auth0Dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  Future<AuthResponseModel> login(String email, String password) async {
    _ensureAuth0Configured();
    final tokenResponse = await _requestAuth0Token(
      email: email,
      password: password,
    );

    try {
      final currentUser = await _getCurrentUserProfile(
        accessToken: tokenResponse['access_token']?.toString(),
      );
      return _buildAuthResponse(tokenResponse, currentUser);
    } on AppException catch (error) {
      if (error.statusCode != 404) rethrow;

      final claims = _parseTokenClaims(tokenResponse['id_token']?.toString());
      final fallbackProfile = await _upsertCurrentUserProfile(
        accessToken: tokenResponse['access_token']?.toString() ?? '',
        email: claims['email']?.toString() ?? email,
        firstName: _resolveFirstName(claims, email),
        lastName: _resolveLastName(claims),
        phone: null,
      );
      return _buildAuthResponse(tokenResponse, fallbackProfile);
    }
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
    _ensureAuth0Configured();
    await _auth0Signup(email: email, password: password);

    final tokenResponse = await _requestAuth0Token(
      email: email,
      password: password,
    );
    final userProfile = await _upsertCurrentUserProfile(
      accessToken: tokenResponse['access_token']?.toString() ?? '',
      email: email,
      firstName: _firstName(name),
      lastName: _lastName(name),
      phone: phone,
    );
    return _buildAuthResponse(tokenResponse, userProfile);
  }

  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    return _getCurrentUserProfile();
  }

  Future<void> logout() async {
    return;
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

  Future<void> _auth0Signup({
    required String email,
    required String password,
  }) async {
    try {
      await _auth0Dio.post(
        Auth0Config.signupUrl,
        data: {
          'client_id': Auth0Config.clientId,
          'email': email,
          'password': password,
          'connection': Auth0Config.connection,
        },
      );
    } on DioException catch (error) {
      throw _mapAuth0Exception(error);
    }
  }

  Future<Map<String, dynamic>> _requestAuth0Token({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth0Dio.post(
        Auth0Config.oauthTokenUrl,
        data: {
          'grant_type': 'http://auth0.com/oauth/grant-type/password-realm',
          'client_id': Auth0Config.clientId,
          'username': email,
          'password': password,
          'audience': Auth0Config.audience,
          'scope': 'openid profile email offline_access',
          'realm': Auth0Config.connection,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      throw _mapAuth0Exception(error);
    }
  }

  Future<Map<String, dynamic>> _getCurrentUserProfile({
    String? accessToken,
  }) async {
    final response = await _dioClient.get(
      Endpoints.currentUser,
      options: accessToken == null || accessToken.isEmpty
          ? null
          : Options(
              headers: {'Authorization': 'Bearer $accessToken'},
            ),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _upsertCurrentUserProfile({
    required String accessToken,
    required String email,
    required String firstName,
    required String lastName,
    required String? phone,
  }) async {
    final response = await _dioClient.put(
      Endpoints.currentUser,
      data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  AuthResponseModel _buildAuthResponse(
    Map<String, dynamic> tokenResponse,
    Map<String, dynamic> userResponse,
  ) {
    final accessToken = tokenResponse['access_token']?.toString() ?? '';
    final refreshToken = tokenResponse['refresh_token']?.toString() ?? '';
    final expiresIn =
        int.tryParse(tokenResponse['expires_in']?.toString() ?? '') ?? 3600;

    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: UserModel.fromJson(userResponse),
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  Map<String, dynamic> _parseTokenClaims(String? token) {
    if (token == null || token.isEmpty) return const {};
    final parts = token.split('.');
    if (parts.length < 2) return const {};
    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final parsed = jsonDecode(decoded);
      return parsed is Map<String, dynamic> ? parsed : const {};
    } catch (_) {
      return const {};
    }
  }

  String _resolveFirstName(Map<String, dynamic> claims, String email) {
    final givenName = claims['given_name']?.toString();
    if (givenName != null && givenName.isNotEmpty) return givenName;

    final fullName = claims['name']?.toString();
    if (fullName != null && fullName.trim().isNotEmpty) {
      return _firstName(fullName);
    }

    return email.contains('@') ? email.split('@').first : 'Conductor';
  }

  String _resolveLastName(Map<String, dynamic> claims) {
    final familyName = claims['family_name']?.toString();
    if (familyName != null && familyName.isNotEmpty) return familyName;

    final fullName = claims['name']?.toString();
    if (fullName != null && fullName.trim().isNotEmpty) {
      return _lastName(fullName);
    }

    return 'Cobox';
  }

  AppException _mapAuth0Exception(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final description =
          responseData['description']?.toString() ??
          responseData['error_description']?.toString() ??
          responseData['message']?.toString();
      if (description != null && description.isNotEmpty) {
        return AppException(
          description,
          statusCode: error.response?.statusCode,
        );
      }
    }

    return AppException(
      error.message ?? 'No fue posible autenticar con Auth0.',
      statusCode: error.response?.statusCode,
    );
  }

  void _ensureAuth0Configured() {
    if (Auth0Config.isConfigured) return;
    throw const AppException(
      'Falta AUTH0_CLIENT_ID en los dart-defines de la app.',
    );
  }

  String _firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : fullName.trim();
  }

  String _lastName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return 'Conductor';
    return parts.skip(1).join(' ');
  }
}
