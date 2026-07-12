import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource_impl.dart';
import 'package:flutter_ecommerce/features/customizer/data/repositories/custom_design_repository_impl.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/delete_logo_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_custom_design_spec_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_existing_design_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_printing_configs_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/save_custom_design_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/upload_logo_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_design_for_viewer_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/design_viewer_cubit.dart';

void setupCustomizerModule(GetIt sl) {
  sl.registerLazySingleton<CustomDesignRemoteDataSource>(
    () => CustomDesignRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CustomDesignRepository>(
    () => CustomDesignRepositoryImpl(sl<CustomDesignRemoteDataSource>()),
  );
  sl.registerLazySingleton<SaveCustomDesignUseCase>(
    () => SaveCustomDesignUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<GetPrintingConfigsUseCase>(
    () => GetPrintingConfigsUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<GetExistingDesignUseCase>(
    () => GetExistingDesignUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<GetCustomDesignSpecUseCase>(
    () => GetCustomDesignSpecUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<GetDesignForViewerUseCase>(
    () => GetDesignForViewerUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<UploadLogoUseCase>(
    () => UploadLogoUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerLazySingleton<DeleteLogoUseCase>(
    () => DeleteLogoUseCase(sl<CustomDesignRepository>()),
  );
  sl.registerFactory<DesignViewerCubit>(
    () => DesignViewerCubit(sl<GetDesignForViewerUseCase>()),
  );
  sl.registerFactory<CustomizerCubit>(
    () => CustomizerCubit(
      getPrintingConfigs: sl<GetPrintingConfigsUseCase>(),
      saveCustomDesign: sl<SaveCustomDesignUseCase>(),
      getExistingDesign: sl<GetExistingDesignUseCase>(),
      uploadLogo: sl<UploadLogoUseCase>(),
      deleteLogo: sl<DeleteLogoUseCase>(),
    ),
  );
  sl.registerFactory<CustomDesignSpecCubit>(
    () => CustomDesignSpecCubit(
      getCustomDesignSpec: sl<GetCustomDesignSpecUseCase>(),
    ),
  );
}
