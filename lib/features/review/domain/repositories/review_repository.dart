import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_page.dart';

abstract interface class ReviewRepository {
  Future<Result<List<ReviewEntity>>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 5,
  });

  /// Admin: paginated list of every review across all products.
  /// View + reply only — there is no hide/delete capability by design.
  Future<Result<ReviewPage>> getAllReviews({int page = 0, int size = 10});

  /// Admin: attach/replace the seller reply on a review.
  Future<Result<ReviewEntity>> replyToReview(int reviewId, String reply);
}
