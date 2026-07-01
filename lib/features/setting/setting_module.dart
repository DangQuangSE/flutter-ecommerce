import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/setting/data/datasources/site_setting_remote_datasource.dart';
import 'package:flutter_ecommerce/features/setting/data/datasources/site_setting_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/setting/data/repositories/site_setting_repository_impl.dart';
import 'package:flutter_ecommerce/features/setting/domain/repositories/site_setting_repository.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';

void setupSettingModule(GetIt sl) {
  sl.registerLazySingleton<SiteSettingRemoteDataSource>(
    () => SiteSettingRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SiteSettingRepository>(
    () => SiteSettingRepositoryImpl(sl<SiteSettingRemoteDataSource>()),
  );
  sl.registerFactory<SiteSettingCubit>(
    () => SiteSettingCubit(sl<SiteSettingRepository>()),
  );
}
