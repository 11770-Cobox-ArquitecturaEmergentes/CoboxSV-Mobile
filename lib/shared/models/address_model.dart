import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  final String street;
  final String? number;
  final String? colony;
  final String city;
  final String state;
  final String? zipCode;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.street,
    this.number,
    this.colony,
    required this.city,
    required this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  String get fullAddress {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (number != null && number!.isNotEmpty) parts.add(number!);
    if (colony != null && colony!.isNotEmpty) parts.add(colony!);
    parts.add(city);
    parts.add(state);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
