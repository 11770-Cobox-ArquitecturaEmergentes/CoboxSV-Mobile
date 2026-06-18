import 'package:dartz/dartz.dart';

import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/network/network_info.dart';
import 'package:cobox_sv_mobile/features/home/data/datasource/home_local_datasource.dart';
import 'package:cobox_sv_mobile/features/home/data/datasource/home_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';
import 'package:cobox_sv_mobile/features/home/domain/repository/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Dashboard>> getDashboard() async {
    try {
      if (await networkInfo.checkConnectivity()) {
        final model = await remoteDataSource.getDashboard();
        await localDataSource.cacheDashboard(model);
        return Right(model.toEntity());
      }
      final cached = localDataSource.getCachedDashboard();
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return const Left(CacheFailure(message: 'No cached data available'));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Activity>>> getRecentActivity({int limit = 10}) async {
    try {
      if (await networkInfo.checkConnectivity()) {
        final models = await remoteDataSource.getRecentActivity(limit: limit);
        await localDataSource.cacheRecentActivity(models);
        return Right(models.map((m) => m.toEntity()).toList());
      }
      final cached = localDataSource.getCachedRecentActivity();
      if (cached != null) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return const Left(CacheFailure(message: 'No cached data available'));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
