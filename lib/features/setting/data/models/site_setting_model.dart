import 'package:flutter_ecommerce/features/setting/domain/entities/site_setting_entity.dart';

class SiteSettingModel extends SiteSettingEntity {
  const SiteSettingModel({required super.returnPolicy});

  factory SiteSettingModel.fromJson(Map<String, dynamic> json) {
    return SiteSettingModel(
      returnPolicy: json['returnPolicy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'returnPolicy': returnPolicy};
  }
}
