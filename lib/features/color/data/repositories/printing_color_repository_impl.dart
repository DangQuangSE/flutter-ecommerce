import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/printing_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/models/printing_color_model.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/printing_color_entity.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/printing_color_repository.dart';

class PrintingColorRepositoryImpl implements PrintingColorRepository {
  final PrintingColorRemoteDataSource _remoteDataSource;

  const PrintingColorRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<PrintingColorEntity>>> getColors() async {
    try {
      final models = await _remoteDataSource.getColors();
      return Success(models);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<PrintingColorEntity>> createColor(
      PrintingColorEntity color) async {
    try {
      final model = PrintingColorModel.fromEntity(color);
      final result = await _remoteDataSource.createColor(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<PrintingColorEntity>> updateColor(
      int id, PrintingColorEntity color) async {
    try {
      final model = PrintingColorModel.fromEntity(color);
      final result = await _remoteDataSource.updateColor(id, model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteColor(int id) async {
    try {
      await _remoteDataSource.deleteColor(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
