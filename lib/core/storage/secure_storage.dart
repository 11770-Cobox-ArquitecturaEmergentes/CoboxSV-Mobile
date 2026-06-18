import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _Keys.token, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _Keys.token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _Keys.token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _Keys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _Keys.refreshToken);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final json = jsonEncode(userData);
    await _storage.write(key: _Keys.userData, value: json);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final json = await _storage.read(key: _Keys.userData);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> saveObject<T>(String key, T value) async {
    final json = jsonEncode(value);
    await _storage.write(key: key, value: json);
  }

  Future<T?> readObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final json = await _storage.read(key: key);
    if (json == null) return null;
    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) {
      return fromJson(decoded);
    }
    return null;
  }

  Future<void> saveList<T>(String key, List<T> list) async {
    final json = jsonEncode(list);
    await _storage.write(key: key, value: json);
  }

  Future<List<T>?> readList<T>(String key, T Function(dynamic) fromJson) async {
    final json = await _storage.read(key: key);
    if (json == null) return null;
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => fromJson(e)).toList();
    }
    return null;
  }
}

class _Keys {
  static const String token = 'auth_token';
  static const String refreshToken = 'auth_refresh_token';
  static const String userData = 'auth_user_data';
}
