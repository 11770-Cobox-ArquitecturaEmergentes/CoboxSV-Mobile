import 'dart:io';

import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_local_datasource.dart';
import 'package:cobox_sv_mobile/features/profile/data/models/profile_model.dart';
import 'package:cobox_sv_mobile/features/profile/data/models/vehicle_model.dart';

class ProfileRemoteDataSource {
  final DioClient _client;
  final AuthLocalDataSource _authLocalDataSource;

  ProfileRemoteDataSource(this._client, this._authLocalDataSource);

  Future<ProfileModel> getProfile() async {
    final currentUser = await _authLocalDataSource.getUser();
    final currentUserId = currentUser?.id;
    final currentUserEmail = currentUser?.email;

    if (currentUserId == null || currentUserId.isEmpty || currentUserEmail == null || currentUserEmail.isEmpty) {
      throw const ServerException('No se pudo resolver el usuario actual');
    }

    final userData = await _safeGet('${Endpoints.users}/$currentUserId') ?? _currentUserToMap(currentUser);
    final driverData = await _safeGetDriverByEmail(currentUserEmail);
    final driverId = driverData?['id']?.toString() ?? currentUserId;
    final routes = await _safeGetList(Endpoints.driverRoutes(driverId));

    final activeRoute = routes.cast<Map<String, dynamic>?>().firstWhere(
          (route) => route?['routeStatus']?.toString() == 'IN_PROGRESS',
          orElse: () => routes.isNotEmpty
              ? routes.first as Map<String, dynamic>
              : null,
        );

    final vehicleId = activeRoute?['vehicleId']?.toString();
    final vehicleData = vehicleId == null
        ? null
        : await _safeGet('${Endpoints.vehicles}/$vehicleId');

    return ProfileModel(
      id: currentUserId,
      name: _resolveName(userData),
      email: userData['email']?.toString() ?? '',
      phone: userData['phone']?.toString(),
      photoUrl: null,
      employeeId: 'USR-$currentUserId',
      licenseNumber: driverData?['licenceNumber']?.toString(),
      licenseExpiry: null,
      role: _resolveRole(userData),
      isActive: true,
      vehicle: vehicleData == null ? null : _vehicleFromBackend(vehicleData),
    );
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    throw const AppException(
      'El backend actual no expone actualizacion de perfil',
    );
  }

  Future<String> uploadPhoto(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw const AppException('File not found');
    }
    throw const AppException(
      'El backend actual no expone carga de foto de perfil',
    );
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    throw const AppException(
      'El backend actual no expone cambio de contrasena',
    );
  }

  Future<Map<String, dynamic>?> _safeGet(String path) async {
    try {
      final response = await _client.get(path);
      return response.data as Map<String, dynamic>?;
    } on AppException catch (error) {
      if (_shouldIgnoreFleetError(error)) {
        return null;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _safeGetDriverByEmail(String email) async {
    try {
      final response = await _client.get(
        Endpoints.driverSearch,
        queryParameters: {'email': email},
      );
      return response.data as Map<String, dynamic>?;
    } on AppException catch (error) {
      if (_shouldIgnoreFleetError(error)) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<dynamic>> _safeGetList(String path) async {
    try {
      final response = await _client.get(path);
      return response.data as List<dynamic>? ?? const [];
    } on AppException catch (error) {
      if (_shouldIgnoreFleetError(error)) {
        return const [];
      }
      rethrow;
    }
  }

  bool _shouldIgnoreFleetError(AppException error) {
    final message = error.message.toLowerCase();
    return error.statusCode == 404 ||
        error.statusCode == 500 &&
            (message.contains('driver not found') ||
                message.contains('contexto fleet'));
  }

  Map<String, dynamic> _currentUserToMap(dynamic currentUser) {
    return {
      'id': currentUser?.id,
      'email': currentUser?.email,
      'name': currentUser?.name,
      'phone': currentUser?.phone,
      'roles': currentUser?.role != null ? [currentUser.role] : ['ROLE_DRIVER'],
    };
  }

  String _resolveName(Map<String, dynamic> userData) {
    final firstName = userData['firstName']?.toString() ?? '';
    final lastName = userData['lastName']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) return fullName;
    final fallbackName = userData['name']?.toString() ?? '';
    if (fallbackName.isNotEmpty) return fallbackName;
    final email = userData['email']?.toString() ?? '';
    if (email.contains('@')) return email.split('@').first;
    return 'Usuario';
  }

  String _resolveRole(Map<String, dynamic> userData) {
    final roles = userData['roles'];
    if (roles is List && roles.isNotEmpty) {
      return roles.first.toString();
    }
    final role = userData['role']?.toString();
    if (role != null && role.isNotEmpty) {
      return role;
    }
    return 'ROLE_DRIVER';
  }

  VehicleModel _vehicleFromBackend(Map<String, dynamic> vehicleData) {
    return VehicleModel(
      id: vehicleData['id']?.toString() ?? '',
      plate: vehicleData['plateNumber']?.toString() ?? '-',
      brand: 'Vehiculo',
      model: vehicleData['vehicleStatus']?.toString() ?? 'Asignado',
      year: DateTime.now().year,
      type: 'Flota',
      color: 'No especificado',
      capacity: (vehicleData['capacityKg'] as num?)?.toDouble() ?? 0,
      fuelType: 'No especificado',
      lastMaintenance: null,
      nextMaintenance: null,
    );
  }
}
