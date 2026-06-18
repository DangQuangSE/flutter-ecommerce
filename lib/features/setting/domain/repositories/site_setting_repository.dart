import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/setting/domain/entities/site_setting_entity.dart';

abstract interface class SiteSettingRepository {
  Future<Result<SiteSettingEntity>> getSettings();
  Future<Result<SiteSettingEntity>> updateSettings(String returnPolicy);
}
