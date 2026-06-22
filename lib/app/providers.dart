export 'package:cobox_sv_mobile/app/router.dart' show AuthStatus;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cobox_sv_mobile/app/router.dart';
import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/network/network_info.dart';
import 'package:cobox_sv_mobile/core/storage/local_storage.dart';
import 'package:cobox_sv_mobile/core/storage/secure_storage.dart';

final authStatusProvider = StateProvider<AuthStatus>((ref) => AuthStatus.unauthenticated);

final routerRefreshProvider = Provider<ValueNotifier<AuthStatus>>((ref) {
  final notifier = ValueNotifier<AuthStatus>(ref.read(authStatusProvider));
  ref.listen<AuthStatus>(authStatusProvider, (_, next) {
    notifier.value = next;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final localeProvider = StateProvider<Locale>((ref) => const Locale('es'));

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(storage: ref.watch(flutterSecureStorageProvider));
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override this provider with SharedPreferences instance');
});

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage(ref.watch(sharedPreferencesProvider));
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});

final connectivityProvider = StreamProvider<bool>((ref) {
  return ref.watch(networkInfoProvider).isConnected;
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient.getInstance(
    secureStorage: ref.watch(flutterSecureStorageProvider),
  );
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = createRouter(
    ref,
    refreshListenable: ref.watch(routerRefreshProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});
