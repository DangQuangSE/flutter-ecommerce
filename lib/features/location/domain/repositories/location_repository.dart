import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/location/data/models/location_model.dart';

abstract interface class LocationRepository {
  Future<Result<List<LocationModel>>> getProvinces();
  Future<Result<List<LocationModel>>> getDistricts(int provinceCode);
  Future<Result<List<LocationModel>>> getWards(int districtCode);
}
