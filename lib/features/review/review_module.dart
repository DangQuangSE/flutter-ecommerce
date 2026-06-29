import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource.dart';
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/review/data/repositories/review_repository_impl.dart';
import 'package:flutter_ecommerce/features/review/domain/repositories/review_repository.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/admin_review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/write_review_cubit.dart';

void setupReviewModule(GetIt sl) {
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewRemoteDataSource>()),
  );
  sl.registerFactory<ReviewCubit>(
    () => ReviewCubit(sl<ReviewRepository>()),
  );
  sl.registerFactory<AdminReviewCubit>(
    () => AdminReviewCubit(sl<ReviewRepository>()),
  );
  sl.registerFactory<WriteReviewCubit>(
    () => WriteReviewCubit(sl<ReviewRepository>()),
  );
}
