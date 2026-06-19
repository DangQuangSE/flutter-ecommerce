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

  // Order list / detail (customer-facing)
  static const String orderListSectionLabel = 'QUẢN LÝ GIAO DỊCH';
  static const String orderListTitle = 'Đơn Hàng Của Tôi';
  static const String orderFilterAll = 'Tất cả';
  static const String orderEmptyTitle = 'Không có đơn hàng nào';
  static const String orderEmptySubtitle =
      'Các giao dịch thuộc danh mục này sẽ xuất hiện tại đây.';
  static const String orderListLoadError =
      'Không thể tải đơn hàng. Vui lòng thử lại sau.';
  static const String orderQuantityLabel = 'Số lượng';
  static const String orderDetailLoadError =
      'Không thể tải chi tiết đơn hàng. Vui lòng thử lại sau.';
  static const String orderInfoSectionTitle = 'THÔNG TIN ĐƠN HÀNG';
  static const String orderCodeLabel = 'Mã đơn hàng';
  static const String orderDateLabel = 'Ngày đặt';
  static const String orderPaymentMethodLabel = 'Phương thức thanh toán';
  static const String orderShippingAddressSectionTitle = 'ĐỊA CHỈ GIAO HÀNG';
  static const String orderShippingAddressLabel = 'Địa chỉ';
  static String orderProductsSectionTitle(int count) => 'SẢN PHẨM ($count)';
  static const String orderSizeLabel = 'Size';
  static const String orderTotalLabel = 'TỔNG THANH TOÁN';
  static const String orderContinueShopping = 'TIẾP TỤC MUA SẮM';
  static const String orderWriteReviewAction = 'Đánh giá';
  static const String orderReviewedLabel = 'Đã đánh giá';

  // Write review
  static const String writeReviewTitle = 'Đánh giá sản phẩm';
  static const String writeReviewRatingLabel =
      'Bạn đánh giá sản phẩm này bao nhiêu sao?';
  static const String writeReviewCommentLabel = 'Nhận xét của bạn';
  static const String writeReviewCommentHint =
      'Chia sẻ cảm nhận của bạn về sản phẩm...';
  static const String writeReviewAddImage = 'Thêm ảnh';
  static const String writeReviewSubmit = 'Gửi đánh giá';
  static const String writeReviewRatingRequired = 'Vui lòng chọn số sao';
  static const String writeReviewCommentRequired = 'Vui lòng nhập nhận xét';
  static const String writeReviewSubmitSuccess = 'Đã gửi đánh giá. Cảm ơn bạn!';
  static String writeReviewMaxImages(int max) =>
      'Chỉ được chọn tối đa $max ảnh';

  // Address management
  static const String addressListTitle = 'Địa chỉ của tôi';
  static const String addressEmptyTitle = 'Chưa có địa chỉ nào';
  static const String addressEmptySubtitle =
      'Thêm địa chỉ để thuận tiện khi đặt hàng.';
  static const String addressAdd = 'Thêm địa chỉ';
  static const String addressEdit = 'Sửa địa chỉ';
  static const String addressDelete = 'Xóa địa chỉ';
  static const String addressDeleteConfirm =
      'Bạn có chắc muốn xóa địa chỉ này?';
  static const String addressSetDefault = 'Đặt mặc định';
  static const String addressDefaultLabel = 'Mặc định';
  static const String addressSave = 'Lưu địa chỉ';
  static const String addressUpdate = 'Cập nhật';
  static const String addressCancel = 'Hủy';
  static const String addressFormTitle = 'Địa chỉ mới';
  static const String addressFormEditTitle = 'Sửa địa chỉ';
  static const String addressFullNameHint = 'Họ và tên';
  static const String addressPhoneHint = 'Số điện thoại';
  static const String addressLineHint = 'Số nhà, đường';
  static const String addressWardHint = 'Phường / Xã';
  static const String addressDistrictHint = 'Quận / Huyện';
  static const String addressCityHint = 'Tỉnh / Thành phố';
  static const String addressLabelHint = 'Nhãn (Ví dụ: Nhà, Công ty)';
  static const String addressIsDefaultHint = 'Đặt làm địa chỉ mặc định';
  static const String addressFullNameRequired = 'Vui lòng nhập họ và tên';
  static const String addressPhoneRequired = 'Vui lòng nhập số điện thoại';
  static const String addressLineRequired = 'Vui lòng nhập địa chỉ';
  static const String addressWardRequired = 'Vui lòng nhập phường / xã';
  static const String addressDistrictRequired = 'Vui lòng nhập quận / huyện';
  static const String addressCityRequired = 'Vui lòng nhập tỉnh / thành phố';
  static const String addressCreated = 'Đã thêm địa chỉ thành công!';
  static const String addressUpdated = 'Đã cập nhật địa chỉ thành công!';
  static const String addressDeleted = 'Đã xóa địa chỉ thành công!';
  static const String addressSetDefaultSuccess =
      'Đã đặt địa chỉ mặc định thành công!';
  static const String addressLoadError =
      'Không thể tải địa chỉ. Vui lòng thử lại sau.';

  // ── Shop info (user-facing) ────────────────────────────────────────────────
  static const String shopInfoTitle = 'Thông tin cửa hàng';
  static const String shopDescriptionLabel = 'MÔ TẢ';
  static String shopRatingCount(int count) => '($count đánh giá)';
  static const String shopLoadError =
      'Không thể tải thông tin cửa hàng. Vui lòng thử lại sau.';

  // ── Admin shop config ─────────────────────────────────────────────────────
  static const String adminShopConfigTitle = 'Cấu hình cửa hàng';
  static const String shopSaveChanges = 'Lưu thay đổi';
  static const String shopUpdateSuccess =
      'Đã cập nhật thông tin cửa hàng thành công!';
  static const String shopUpdateError =
      'Cập nhật cửa hàng thất bại. Vui lòng thử lại.';

  // Shop form field labels
  static const String shopFieldName = 'Tên cửa hàng *';
  static const String shopFieldNameHint = 'Nhập tên cửa hàng';
  static const String shopFieldAddress = 'Địa chỉ';
  static const String shopFieldAddressHint = 'Nhập địa chỉ cửa hàng';
  static const String shopFieldRating = 'Đánh giá (0.0 – 5.0)';
  static const String shopFieldRatingHint = 'Ví dụ: 4.8';
  static const String shopFieldRatingCount = 'Số lượt đánh giá';
  static const String shopFieldRatingCountHint = 'Ví dụ: 1200';
  static const String shopFieldPhone = 'Số điện thoại';
  static const String shopFieldPhoneHint = 'Nhập số điện thoại liên hệ';
  static const String shopFieldOpeningHours = 'Giờ mở cửa';
  static const String shopFieldOpeningHoursHint =
      'Ví dụ: 8:00 – 21:00 (T2 – CN)';
  static const String shopFieldDescription = 'Mô tả cửa hàng';
  static const String shopFieldDescriptionHint =
      'Nhập mô tả ngắn về cửa hàng...';
  static const String shopFieldLogoUrl = 'URL Logo';
  static const String shopFieldLogoUrlHint =
      'Nhập đường dẫn ảnh logo cửa hàng';
  static const String shopFieldCoverUrl = 'URL Ảnh bìa';
  static const String shopFieldCoverUrlHint =
      'Nhập đường dẫn ảnh bìa cửa hàng';

  // Shop form validation
  static const String shopValidationNameRequired =
      'Tên cửa hàng không được để trống';
  static const String shopValidationRatingInvalid =
      'Đánh giá phải là số thực (ví dụ: 4.8)';
  static const String shopValidationRatingRange =
      'Đánh giá phải nằm trong khoảng 0.0 – 5.0';
  static const String shopValidationRatingCountInvalid =
      'Số lượt đánh giá phải là số nguyên không âm';

  // Shop entry points
  static const String shopInfoMenuLabel = 'Thông tin cửa hàng';
  static const String adminShopConfigMenuLabel = 'Cấu hình cửa hàng';
}
