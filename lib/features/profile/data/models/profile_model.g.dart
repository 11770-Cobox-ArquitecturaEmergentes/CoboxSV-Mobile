// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  photoUrl: json['photo_url'] as String?,
  employeeId: json['employee_id'] as String?,
  licenseNumber: json['license_number'] as String?,
  licenseExpiry: json['license_expiry'] == null
      ? null
      : DateTime.parse(json['license_expiry'] as String),
  role: json['role'] as String,
  isActive: json['is_active'] as bool? ?? true,
  vehicle: json['vehicle'] == null
      ? null
      : VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'photo_url': instance.photoUrl,
      'employee_id': instance.employeeId,
      'license_number': instance.licenseNumber,
      'license_expiry': instance.licenseExpiry?.toIso8601String(),
      'role': instance.role,
      'is_active': instance.isActive,
      'vehicle': instance.vehicle,
    };
