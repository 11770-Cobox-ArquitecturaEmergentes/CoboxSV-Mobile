import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/core/utils/either.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/repository/auth_repository.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/usecases/login_usecase.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/usecases/signup_usecase.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_local_datasource.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/fleet_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/authentication/data/repository/auth_repository_impl.dart';

final useMockApiProvider = StateProvider<bool>((ref) => false);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(dioClient: ref.watch(dioClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(secureStorage: ref.watch(secureStorageProvider));
});

final fleetRemoteDataSourceProvider = Provider<FleetRemoteDataSource>((ref) {
  return FleetRemoteDataSource(ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    fleetRemoteDataSource: ref.watch(fleetRemoteDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.watch(authRepositoryProvider));
});

final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  return SignupUseCase(repository: ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(repository: ref.watch(authRepositoryProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(repository: ref.watch(authRepositoryProvider));
});

enum AuthStateType { loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStateType type;
  final UserEntity? user;
  final String? error;

  const AuthState({required this.type, this.user, this.error});

  factory AuthState.loading() => const AuthState(type: AuthStateType.loading);

  factory AuthState.authenticated(UserEntity user) =>
      AuthState(type: AuthStateType.authenticated, user: user);

  factory AuthState.unauthenticated() =>
      const AuthState(type: AuthStateType.unauthenticated);

  factory AuthState.error(String message) =>
      AuthState(type: AuthStateType.error, error: message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required SignupUseCase signupUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _signupUseCase = signupUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthState(type: AuthStateType.unauthenticated));

  Future<void> login(String email, String password) async {
    state = const AuthState(type: AuthStateType.loading);
    try {
      final result = await _loginUseCase(
        LoginParams(email: email, password: password),
      );
      switch (result) {
        case Left(value: final Failure failure):
          state = AuthState.error(failure.message);
        case Right(value: final UserEntity user):
          if (_isDriverUser(user)) {
            state = AuthState.authenticated(user);
          } else {
            await _logoutUseCase();
            state = AuthState.error(
              'Esta aplicacion movil esta disponible solo para conductores.',
            );
          }
      }
    } catch (e) {
      state = AuthState.error('Error inesperado al iniciar sesión');
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenceNumber,
  }) async {
    state = const AuthState(type: AuthStateType.loading);
    try {
      final result = await _signupUseCase(
        SignupParams(
          name: name,
          email: email,
          password: password,
          phone: phone,
          licenceNumber: licenceNumber,
        ),
      );
      switch (result) {
        case Left(value: final Failure failure):
          state = AuthState.error(failure.message);
        case Right(value: final UserEntity user):
          if (_isDriverUser(user)) {
            state = AuthState.authenticated(user);
          } else {
            await _logoutUseCase();
            state = AuthState.error(
              'La cuenta creada no pertenece a un conductor.',
            );
          }
      }
    } catch (e) {
      state = AuthState.error('Error inesperado al registrarse');
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase();
    } catch (_) {
      // Continue with local cleanup even if remote logout fails
    }
    state = const AuthState(type: AuthStateType.unauthenticated);
  }

  Future<void> checkAuth() async {
    state = const AuthState(type: AuthStateType.loading);
    try {
      final result = await _getCurrentUserUseCase();
      switch (result) {
        case Left():
          state = const AuthState(type: AuthStateType.unauthenticated);
        case Right(value: final UserEntity user):
          if (_isDriverUser(user)) {
            state = AuthState.authenticated(user);
          } else {
            await _logoutUseCase();
            state = const AuthState(type: AuthStateType.unauthenticated);
          }
      }
    } catch (_) {
      state = const AuthState(type: AuthStateType.unauthenticated);
    }
  }

  bool _isDriverUser(UserEntity user) => user.role == 'driver';
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    signupUseCase: ref.watch(signupUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});
