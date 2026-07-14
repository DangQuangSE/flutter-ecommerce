/// Product and customizer feature strings
abstract final class ProductStrings {
  // Customizer
  static const String customizerTitle = 'Tùy chỉnh sản phẩm';
  static const String customizerAddText = 'Thêm chữ';
  static const String customizerAddImage = 'Thêm ảnh';
  static const String customizerLayers = 'Tầng xếp lớp';
  static const String customizerUndo = 'Hoàn tác';
  static const String customizerRedo = 'Làm lại';
  static const String customizerSave = 'Lưu thiết kế';
  static const String customizerPreview = 'Xem trước';
  static const String customizerReset = 'Đặt lại';
  static const String customizerFontLabel = 'Font chữ';
  static const String customizerColorLabel = 'Màu sắc';
  static const String customizerSizeLabel = 'Kích thước';
  static const String customizerRotationLabel = 'Xoay';
  static const String customizerOpacityLabel = 'Độ trong suốt';
  static const String customizerTextColor = 'Màu chữ';
  static const String customizerBackgroundColor = 'Màu nền';
  static const String customizerNoLayers = 'Chưa có tầng nào';
  static const String customizerLayerText = 'Chữ';
  static const String customizerLayerImage = 'Ảnh';
  static const String customizerLayerShape = 'Hình';
  static const String customizerDeleteLayer = 'Xóa tầng';
  static const String customizerDuplicateLayer = 'Nhân bản';
  static const String customizerMoveUp = 'Di chuyển lên';
  static const String customizerMoveDown = 'Di chuyển xuống';
  static const String customizerProductName = 'Sản phẩm';
  static const String customizerDesignName = 'Tên thiết kế';
  static const String customizerDesignNameHint = 'Nhập tên thiết kế';
  static const String customizerSaveSuccess = 'Đã lưu thiết kế';
  static const String customizerSaveError = 'Lỗi khi lưu thiết kế';
  static const String customizerLoadError = 'Lỗi khi tải thiết kế';
  static const String customizerEmptyDesign = 'Thiết kế trống';
  static const String customizerConfirmDelete = 'Xóa thiết kế?';
  static const String customizerConfirmDeleteMessage = 'Bạn có chắc muốn xóa thiết kế này?';
  static const String customizerTotalProduct = 'TỔNG CỘNG SẢN PHẨM';
  static const String customizerPrintingPriceLabel = 'Giá in thêm';
  static const String customizerPrintingPriceHint = '(Theo số lớp & logo)';
  static const String customizerSelectedColor = 'Selected Color';
  static String customizerSportFontLabel(String font) => '$font ($customizerSportFontSuffix)';
  static String customizerPrintingPrice(String price) => '$customizerPrintingPriceLabel: $price ₫';
  static const String customizerSportFontSuffix = 'Sport Pro Font';

  // Product detail
  static const String detailTitle = 'Chi tiết sản phẩm';
  static const String detailSpecifications = 'Thông số kỹ thuật';
  static const String detailReviews = 'Đánh giá';
  static const String detailAddToCart = 'THÊM VÀO GIỎ';
  static const String detailBuyNow = 'MUA NGAY';
  static const String detailSelectSize = 'Chọn kích thước';
  static const String detailSelectColor = 'Chọn màu sắc';
  static const String detailOutOfStock = 'Hết hàng';
  static const String detailInStock = 'Còn hàng';
  static const String detailSizeGuide = 'Hướng dẫn kích thước';
  static const String detailShippingInfo = 'Thông tin giao hàng';
  static const String detailReturnPolicy = 'Chính sách đổi trả';
  static const String detailWriteReview = 'Viết đánh giá';
  static const String detailNoReviews = 'Chưa có đánh giá';
  static const String detailBeFirstReview = 'Hãy là người đầu tiên đánh giá sản phẩm này';
  static const String detailRating = 'Đánh giá';
  static const String detailYourReview = 'Đánh giá của bạn';
  static const String detailReviewTitle = 'Tiêu đề đánh giá';
  static const String detailReviewContent = 'Nội dung đánh giá';
  static const String detailReviewSubmit = 'Gửi đánh giá';
  static const String detailReviewSuccess = 'Đã gửi đánh giá';
  static const String detailReviewError = 'Lỗi khi gửi đánh giá';
  static const String detailRelatedProducts = 'Sản phẩm liên quan';
  static const String detailShareProduct = 'Chia sẻ sản phẩm';

  // Product list/filter
  static const String filterTitle = 'Bộ lọc';
  static const String filterApply = 'Áp dụng';
  static const String filterClear = 'Xóa bộ lọc';
  static const String filterPrice = 'Giá';
  static const String filterCategory = 'Danh mục';
  static const String filterBrand = 'Thương hiệu';
  static const String filterSize = 'Kích thước';
  static const String filterColor = 'Màu sắc';
  static const String filterGender = 'Giới tính';
  static const String filterSortBy = 'Sắp xếp theo';
  static const String filterSortNewest = 'Mới nhất';
  static const String filterSortPriceLow = 'Giá thấp đến cao';
  static const String filterSortPriceHigh = 'Giá cao đến thấp';
  static const String filterSortPopular = 'Phổ biến nhất';
  static String filterPriceBetween(String min, String max) => '$min - $max';
  static String filterPriceFrom(String price) => 'Từ $price';
  static String filterPriceTo(String price) => 'Đến $price';

  // Wishlist
  static const String wishlistTitle = 'Danh sách yêu thích';
  static const String wishlistEmpty = 'Chưa có sản phẩm yêu thích';
  static const String wishlistAddSuccess = 'Đã thêm vào yêu thích';
  static const String wishlistRemoveSuccess = 'Đã xóa khỏi yêu thích';
}
