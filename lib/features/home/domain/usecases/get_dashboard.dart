import 'package:dartz/dartz.dart';

import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';
import 'package:cobox_sv_mobile/features/home/domain/repository/home_repository.dart';

class GetDashboard {
  final HomeRepository repository;

  GetDashboard(this.repository);

  Future<Either<Failure, Dashboard>> call() => repository.getDashboard();
}
