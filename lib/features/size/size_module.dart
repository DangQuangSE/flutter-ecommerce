import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/size/data/datasources/size_group_remote_datasource.dart';
import 'package:flutter_ecommerce/features/size/data/datasources/size_group_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/size/data/repositories/size_group_repository_impl.dart';
import 'package:flutter_ecommerce/features/size/domain/repositories/size_group_repository.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/create_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/delete_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/get_size_groups_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/update_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';

void setupSizeModule(GetIt sl) {
  sl.registerLazySingleton<SizeGroupRemoteDatasource>(
    () => SizeGroupRemoteDatasourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SizeGroupRepository>(
    () => SizeGroupRepositoryImpl(sl<SizeGroupRemoteDatasource>()),
  );
  sl.registerFactory<GetSizeGroupsUseCase>(
    () => GetSizeGroupsUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<CreateSizeGroupUseCase>(
    () => CreateSizeGroupUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<UpdateSizeGroupUseCase>(
    () => UpdateSizeGroupUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<DeleteSizeGroupUseCase>(
    () => DeleteSizeGroupUseCase(sl<SizeGroupRepository>()),
  );
  sl.registerFactory<SizeGroupCubit>(
    () => SizeGroupCubit(
      getSizeGroupsUseCase: sl<GetSizeGroupsUseCase>(),
      createSizeGroupUseCase: sl<CreateSizeGroupUseCase>(),
      updateSizeGroupUseCase: sl<UpdateSizeGroupUseCase>(),
      deleteSizeGroupUseCase: sl<DeleteSizeGroupUseCase>(),
    ),
  );
}
