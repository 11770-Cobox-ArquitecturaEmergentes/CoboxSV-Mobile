import 'package:cobox_sv_mobile/core/storage/secure_storage.dart';
import 'package:cobox_sv_mobile/shared/models/user_model.dart';

class AuthLocalDataSource {
  final SecureStorage _secureStorage;

  AuthLocalDataSource({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.save(_credentialsEmailKey, email);
    await _secureStorage.save(_credentialsPasswordKey, password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final email = await _secureStorage.read(_credentialsEmailKey);
    final password = await _secureStorage.read(_credentialsPasswordKey);
    if (email == null || password == null) return null;
    return {'email': email, 'password': password};
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(_credentialsEmailKey);
    await _secureStorage.delete(_credentialsPasswordKey);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.saveToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.getToken();
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }

  Future<void> clearTokens() async {
    await _secureStorage.deleteToken();
    await _secureStorage.delete(_secureRefreshTokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    await _secureStorage.saveObject(_userKey, user.toJson());
  }

  Future<UserModel?> getUser() async {
    return await _secureStorage.readObject<UserModel>(
      _userKey,
      UserModel.fromJson,
    );
  }

  Future<void> clearUser() async {
    await _secureStorage.delete(_userKey);
  }

  static const String _credentialsEmailKey = 'auth_credentials_email';
  static const String _credentialsPasswordKey = 'auth_credentials_password';
  static const String _userKey = 'auth_user_data';
  static const String _secureRefreshTokenKey = 'auth_refresh_token';
}
