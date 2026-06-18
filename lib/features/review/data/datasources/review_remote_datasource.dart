import 'package:flutter_ecommerce/features/review/data/models/review_model.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_page.dart';

abstract interface class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 5,
  });

  Future<ReviewPage> getAllReviews({int page = 0, int size = 10});

  Future<ReviewModel> replyToReview(int reviewId, String reply);

  /// Customer: submit a review for a delivered order item.
  /// [imagePaths] are local file paths picked via image_picker.
  Future<ReviewModel> createReview({
    required int orderItemId,
    required int rating,
    required String comment,
    List<String> imagePaths = const [],
  });
}
