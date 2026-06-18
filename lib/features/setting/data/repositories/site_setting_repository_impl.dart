import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/setting/data/datasources/site_setting_remote_datasource.dart';
import 'package:flutter_ecommerce/features/setting/data/models/site_setting_model.dart';
import 'package:flutter_ecommerce/features/setting/domain/entities/site_setting_entity.dart';
import 'package:flutter_ecommerce/features/setting/domain/repositories/site_setting_repository.dart';

class SiteSettingRepositoryImpl implements SiteSettingRepository {
  final SiteSettingRemoteDataSource _remoteDataSource;

  const SiteSettingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<SiteSettingEntity>> getSettings() async {
    try {
      final result = await _remoteDataSource.getSettings();
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<SiteSettingEntity>> updateSettings(String returnPolicy) async {
    try {
      final model = SiteSettingModel(returnPolicy: returnPolicy);
      final result = await _remoteDataSource.updateSettings(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
