import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  Future<bool> save(String key, dynamic value) async {
    if (value is String) return _prefs.setString(key, value);
    if (value is bool) return _prefs.setBool(key, value);
    if (value is int) return _prefs.setInt(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    if (value is List<String>) return _prefs.setStringList(key, value);
    return false;
  }

  dynamic read(String key) => _prefs.get(key);

  Future<bool> delete(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();

  Future<bool> saveString(String key, String value) => _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> saveBool(String key, bool value) => _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> saveInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> saveDouble(String key, double value) => _prefs.setDouble(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);

  Future<bool> saveStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<bool> saveOnboardingComplete(bool value) => _prefs.setBool(_Keys.onboardingComplete, value);

  bool isOnboardingComplete() => _prefs.getBool(_Keys.onboardingComplete) ?? false;

  Future<bool> saveLastSync(DateTime dateTime) => _prefs.setString(_Keys.lastSync, dateTime.toIso8601String());

  DateTime? getLastSync() {
    final value = _prefs.getString(_Keys.lastSync);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<bool> saveLanguage(String languageCode) => _prefs.setString(_Keys.language, languageCode);

  String getLanguage() => _prefs.getString(_Keys.language) ?? 'es';
}

class _Keys {
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastSync = 'last_sync';
  static const String language = 'language';
}
