import 'package:dartz/dartz.dart';

import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';

abstract class HomeRepository {
  Future<Either<Failure, Dashboard>> getDashboard();
  Future<Either<Failure, List<Activity>>> getRecentActivity({int limit = 10});
}
