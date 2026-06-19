import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/location/data/datasources/location_remote_datasource.dart';
import 'package:flutter_ecommerce/features/location/data/models/location_model.dart';
import 'package:flutter_ecommerce/features/location/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource _remoteDataSource;

  const LocationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<LocationModel>>> getProvinces() async {
    try {
      final data = await _remoteDataSource.getProvinces();
      return Success(data);
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LocationModel>>> getDistricts(int provinceCode) async {
    try {
      final data = await _remoteDataSource.getDistricts(provinceCode);
      return Success(data);
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LocationModel>>> getWards(int districtCode) async {
    try {
      final data = await _remoteDataSource.getWards(districtCode);
      return Success(data);
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }
}
