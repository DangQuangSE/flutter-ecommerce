import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/review/data/datasources/review_remote_datasource.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';
import 'package:flutter_ecommerce/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  const ReviewRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<ReviewEntity>>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 5,
  }) async {
    try {
      final result = await _remoteDataSource.getProductReviews(
        productId,
        page: page,
        size: size,
      );
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
