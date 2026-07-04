import 'package:json_annotation/json_annotation.dart';
import 'package:cobox_sv_mobile/shared/models/user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  @JsonKey(name: 'accessToken')
  final String accessToken;

  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  final UserModel user;

  @JsonKey(name: 'expiresAt')
  final DateTime expiresAt;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: (json['accessToken'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      user: UserModel.fromJson(json),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        ...user.toJson(),
      };
}
