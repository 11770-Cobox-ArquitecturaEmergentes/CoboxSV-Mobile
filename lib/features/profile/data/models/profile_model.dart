import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:cobox_sv_mobile/features/profile/data/models/vehicle_model.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @JsonKey(name: 'employee_id')
  final String? employeeId;
  @JsonKey(name: 'license_number')
  final String? licenseNumber;
  @JsonKey(name: 'license_expiry')
  final DateTime? licenseExpiry;
  final String role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final VehicleModel? vehicle;

  const ProfileModel({
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

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      employeeId: employeeId,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      role: role,
      isActive: isActive,
      vehicle: vehicle?.toEntity(),
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      employeeId: entity.employeeId,
      licenseNumber: entity.licenseNumber,
      licenseExpiry: entity.licenseExpiry,
      role: entity.role,
      isActive: entity.isActive,
      vehicle:
          entity.vehicle != null ? VehicleModel.fromEntity(entity.vehicle!) : null,
    );
  }
}
