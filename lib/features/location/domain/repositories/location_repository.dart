import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/location/domain/entities/location_entity.dart';

abstract interface class LocationRepository {
  Future<Result<List<LocationEntity>>> getProvinces();
  Future<Result<List<LocationEntity>>> getDistricts(int provinceCode);
  Future<Result<List<LocationEntity>>> getWards(int districtCode);
}
