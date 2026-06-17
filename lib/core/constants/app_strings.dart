/// Centralized user-facing text. Never hardcode UI strings inline — add a
/// constant here instead, so swapping to a localization framework later
/// only touches this file.
abstract final class AppStrings {
  // Common actions
  static const String retry = 'Thử lại';
  static const String viewCart = 'XEM GIỎ';
  static const String addToCart = 'ADD TO CART';
  static const String outOfStock = 'HẾT HÀNG';

  // Product detail — brand / rating
  static const String brandName = 'Sport Pro';
  static const String noRatingYet = 'Chưa có đánh giá';

  // Product detail — specs panel
  static const String specsTitle = 'THÔNG SỐ KỸ THUẬT';
  static const String noProductDescription = 'Sản phẩm chưa có mô tả.';

  // Product detail — reviews panel
  static const String reviewsLoadError =
      'Không thể tải đánh giá. Vui lòng thử lại sau.';
  static const String noReviewsYet = 'Sản phẩm chưa có đánh giá nào.';
  static const String anonymousReviewer = 'Khách hàng';
  static String reviewsTitle(int count) => 'ĐÁNH GIÁ KHÁCH HÀNG ($count)';

  // Product detail — return policy panel
  static const String returnPolicyTitle = 'CHÍNH SÁCH ĐỔI TRẢ & BẢO HÀNH';
  static const String returnPolicyEmpty = 'Chưa có nội dung chính sách.';
  static const String returnPolicyLoadError =
      'Không thể tải nội dung chính sách. Vui lòng thử lại sau.';
  static const String returnPolicyLoading = 'Đang tải nội dung chính sách...';

  // Product detail — wishlist / cart feedback
  static const String addedToWishlist = 'Đã thêm vào danh sách yêu thích!';
  static const String removedFromWishlist = 'Đã xóa khỏi danh sách yêu thích.';
  static const String productDetailLoadError =
      'Đã xảy ra lỗi khi tải chi tiết sản phẩm.';
  static String addedToCartMessage(String productName, String size) =>
      'Đã thêm $productName (Size $size) vào giỏ hàng!';

  // Admin review management — view + reply only (no hide/delete by design)
  static const String adminReviewsTitle = 'Quản lý đánh giá';
  static const String adminReviewsManagementLabel = 'Quản lý đánh giá';
  static const String adminReviewsEmptyTitle = 'Chưa có đánh giá nào';
  static const String adminReviewsEmptySubtitle =
      'Đánh giá của khách hàng sẽ hiển thị ở đây.';
  static const String adminReviewsLoadError = 'Không tải được đánh giá';
  static String adminReviewsCount(int count) => '$count đánh giá';
  static const String adminReviewReplyLabel = 'Phản hồi của shop';
  static const String adminReviewReplyAction = 'Trả lời';
  static const String adminReviewEditReplyAction = 'Sửa phản hồi';
  static const String adminReviewReplySheetTitle = 'Trả lời đánh giá';
  static const String adminReviewReplyHint = 'Nhập phản hồi cho khách hàng...';
  static const String adminReviewReplySubmit = 'Gửi phản hồi';
  static const String adminReviewReplySuccess = 'Đã gửi phản hồi';
  static const String adminReviewReplyRequired =
      'Vui lòng nhập nội dung phản hồi';
  static const String cancel = 'Huỷ';
}
