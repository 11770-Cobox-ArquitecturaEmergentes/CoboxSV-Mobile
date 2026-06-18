import 'package:equatable/equatable.dart';

import 'package:cobox_sv_mobile/features/profile/domain/entities/vehicle_entity.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? employeeId;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String role;
  final bool isActive;
  final VehicleEntity? vehicle;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.employeeId,
    this.licenseNumber,
    this.licenseExpiry,
    required this.role,
    this.isActive = true,
    this.vehicle,
  });

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? employeeId,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? role,
    bool? isActive,
    VehicleEntity? vehicle,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      employeeId: employeeId ?? this.employeeId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      vehicle: vehicle ?? this.vehicle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        photoUrl,
        employeeId,
        licenseNumber,
        licenseExpiry,
        role,
        isActive,
        vehicle,
      ];
}
