import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/address/data/datasources/address_remote_datasource.dart';
import 'package:flutter_ecommerce/features/address/data/models/address_model.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(this._remoteDataSource);

  final AddressRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<AddressEntity>>> getAddresses() async {
    try {
      final models = await _remoteDataSource.getAddresses();
      return Success(models);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<AddressEntity>> addAddress(AddressEntity address) async {
    try {
      final model = AddressModel.fromEntity(address);
      final result = await _remoteDataSource.addAddress(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<AddressEntity>> updateAddress(AddressEntity address) async {
    try {
      final model = AddressModel.fromEntity(address);
      final result = await _remoteDataSource.updateAddress(address.id!, model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAddress(int id) async {
    try {
      await _remoteDataSource.deleteAddress(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setDefault(int id) async {
    try {
      await _remoteDataSource.setDefault(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
