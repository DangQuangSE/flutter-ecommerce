import 'package:flutter_ecommerce/features/review/data/models/review_model.dart';

abstract interface class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 5,
  });
}
