import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';

abstract interface class ReviewRepository {
  Future<Result<List<ReviewEntity>>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 5,
  });
}
