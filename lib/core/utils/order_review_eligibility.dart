abstract final class OrderReviewEligibility {
  static const String reviewableStatus = 'DELIVERED';

  static bool canReview({
    required String orderStatus,
    required bool isReviewed,
  }) {
    return orderStatus.trim().toUpperCase() == reviewableStatus && !isReviewed;
  }
}
