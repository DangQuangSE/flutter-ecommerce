import 'package:flutter_ecommerce/features/location/data/models/location_model.dart';

abstract interface class LocationRemoteDataSource {
  Future<List<LocationModel>> getProvinces();
  Future<List<LocationModel>> getDistricts(int provinceCode);
  Future<List<LocationModel>> getWards(int districtCode);
}
