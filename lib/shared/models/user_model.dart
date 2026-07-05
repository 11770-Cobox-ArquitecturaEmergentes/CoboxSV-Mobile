import 'package:json_annotation/json_annotation.dart';
import 'package:cobox_sv_mobile/shared/enums/user_role.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final String? vehicleId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.role = UserRole.driver,
    this.vehicleId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final resolvedEmail = (json['email'] ?? '').toString();
    final resolvedName = (json['name'] as String?) ??
        [
          json['firstName'] as String?,
          json['lastName'] as String?,
        ].whereType<String>().where((part) => part.isNotEmpty).join(' ').trim();

    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: resolvedName.isNotEmpty
          ? resolvedName
          : (resolvedEmail.contains('@')
              ? resolvedEmail.split('@').first
              : 'Usuario'),
      email: resolvedEmail,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: _roleFromJson(json),
      vehicleId: json['vehicleId']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _dateFromJson(json['createdAt']),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'role': role.value,
        'vehicleId': vehicleId,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static UserRole _roleFromJson(Map<String, dynamic> json) {
    final directRole = json['role']?.toString();
    if (directRole != null && directRole.isNotEmpty) {
      return UserRole.fromValue(_normalizeRole(directRole));
    }

    final roles = json['roles'];
    if (roles is Iterable && roles.isNotEmpty) {
      return UserRole.fromValue(_normalizeRole(roles.first.toString()));
    }

    return UserRole.driver;
  }

  static String _normalizeRole(String rawRole) {
    switch (rawRole.toUpperCase()) {
      case 'ROLE_MANAGER':
        return UserRole.supervisor.value;
      case 'ROLE_DRIVER':
        return UserRole.driver.value;
      case 'ROLE_CLIENT':
        return UserRole.admin.value;
      default:
        return rawRole.toLowerCase().replaceFirst('role_', '');
    }
  }

  static DateTime _dateFromJson(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
