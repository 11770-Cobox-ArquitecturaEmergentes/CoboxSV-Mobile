import 'package:dartz/dartz.dart';

import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';
import 'package:cobox_sv_mobile/features/home/domain/repository/home_repository.dart';

class GetRecentActivity {
  final HomeRepository repository;

  GetRecentActivity(this.repository);

  Future<Either<Failure, List<Activity>>> call({int limit = 10}) =>
    repository.getRecentActivity(limit: limit);
}
