import 'package:equatable/equatable.dart';

class Activity with EquatableMixin {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final DateTime timestamp;
  final String? relatedId;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.timestamp,
    this.relatedId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    status,
    timestamp,
    relatedId,
  ];
}
