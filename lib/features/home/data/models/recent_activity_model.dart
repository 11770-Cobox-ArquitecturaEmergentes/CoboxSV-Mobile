import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';

part 'recent_activity_model.g.dart';

@JsonSerializable()
class RecentActivityModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final DateTime timestamp;
  final String? relatedId;

  const RecentActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.timestamp,
    this.relatedId,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) =>
    _$RecentActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecentActivityModelToJson(this);

  Activity toEntity() => Activity(
    id: id,
    title: title,
    description: description,
    type: type,
    status: status,
    timestamp: timestamp,
    relatedId: relatedId,
  );
}
