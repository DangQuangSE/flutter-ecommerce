import 'package:flutter_ecommerce/features/setting/data/models/site_setting_model.dart';

abstract interface class SiteSettingRemoteDataSource {
  Future<SiteSettingModel> getSettings();
  Future<SiteSettingModel> updateSettings(SiteSettingModel settings);
}
