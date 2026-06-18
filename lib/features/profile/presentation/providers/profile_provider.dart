import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/profile/data/repository/profile_repository_impl.dart';
import 'package:cobox_sv_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:cobox_sv_mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:cobox_sv_mobile/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:cobox_sv_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:cobox_sv_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:cobox_sv_mobile/features/profile/domain/usecases/upload_photo_usecase.dart';
import 'package:cobox_sv_mobile/app/providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSource(client),
    networkInfo: networkInfo,
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final uploadPhotoUseCaseProvider = Provider<UploadPhotoUseCase>((ref) {
  return UploadPhotoUseCase(ref.watch(profileRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(profileRepositoryProvider));
});

enum ProfileStateStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStateStatus status;
  final ProfileEntity? profile;
  final String? error;
  final bool isSaving;

  const ProfileState({
    this.status = ProfileStateStatus.initial,
    this.profile,
    this.error,
    this.isSaving = false,
  });

  ProfileState copyWith({
    ProfileStateStatus? status,
    ProfileEntity? profile,
    String? error,
    bool? isSaving,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final UploadPhotoUseCase _uploadPhoto;
  final ChangePasswordUseCase _changePassword;

  ProfileNotifier(
    this._getProfile,
    this._updateProfile,
    this._uploadPhoto,
    this._changePassword,
  ) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStateStatus.loading, error: null);
    try {
      final profile = await _getProfile();
      state = state.copyWith(
        status: ProfileStateStatus.loaded,
        profile: profile,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        status: ProfileStateStatus.error,
        error: e.message,
      );
    }
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    state = state.copyWith(isSaving: true);
    try {
      final updated = await _updateProfile(profile);
      state = state.copyWith(
        isSaving: false,
        profile: updated,
        status: ProfileStateStatus.loaded,
      );
    } on Failure catch (e) {
      state = state.copyWith(isSaving: false, error: e.message);
      rethrow;
    }
  }

  Future<String?> uploadPhoto(String filePath) async {
    state = state.copyWith(isSaving: true);
    try {
      final url = await _uploadPhoto(filePath);
      final current = state.profile;
      if (current != null) {
        state = state.copyWith(
          isSaving: false,
          profile: current.copyWith(photoUrl: url),
        );
      }
      return url;
    } on Failure catch (e) {
      state = state.copyWith(isSaving: false, error: e.message);
      return null;
    }
  }

  Future<String?> changePassword(String current, String newPassword) async {
    state = state.copyWith(isSaving: true);
    try {
      await _changePassword(current, newPassword);
      state = state.copyWith(isSaving: false);
      return null;
    } on Failure catch (e) {
      state = state.copyWith(isSaving: false, error: e.message);
      return e.message;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.watch(getProfileUseCaseProvider),
    ref.watch(updateProfileUseCaseProvider),
    ref.watch(uploadPhotoUseCaseProvider),
    ref.watch(changePasswordUseCaseProvider),
  );
});
