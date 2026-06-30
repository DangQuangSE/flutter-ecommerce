/// Centralized user-facing text. Never hardcode UI strings inline — add a
/// constant here instead, so swapping to a localization framework later
/// only touches this file.
abstract final class AppStrings {
  // Checkout
  static const String checkoutTitle = 'THANH TO\u00c1N';
  static const String checkoutShippingSectionTitle =
      'TH\u00d4NG TIN GIAO H\u00c0NG';
  static const String checkoutPaymentSectionTitle =
      'PH\u01af\u01a0NG TH\u1ee8C THANH TO\u00c1N';
  static const String checkoutCouponSectionTitle =
      'M\u00c3 GI\u1ea2M GI\u00c1 (COUPON)';
  static const String checkoutAddressRequired =
      'Vui l\u00f2ng ch\u1ecdn \u0111\u1ecba ch\u1ec9 giao h\u00e0ng!';
  static const String checkoutShippingInfoRequired =
      'Vui l\u00f2ng \u0111i\u1ec1n \u0111\u1ea7y \u0111\u1ee7 th\u00f4ng tin giao h\u00e0ng!';

  // Cart
  static const String cartEmptyTitle = 'GIỎ HÀNG TRỐNG';
  static const String cartEmptyMessage =
      'Bạn chưa thêm bất kỳ sản phẩm nào vào giỏ hàng. Hãy khám phá bộ sưu tập thể thao Pro ngay!';
  static const String cartLoadErrorTitle = 'Không thể tải thông tin giỏ hàng.';
  static const String continueShopping = 'TIẾP TỤC MUA SẮM';

  // Common actions
  static const String retry = 'Thử lại';
  static const String edit = 'Sửa';
  static const String delete = 'Xóa';
  static const String viewCart = 'XEM GIỎ';
  static const String addToCart = 'ADD TO CART';
  static const String outOfStock = 'HẾT HÀNG';

  // Product catalog / filter
  static const String productSearchHint = 'Tìm kiếm sản phẩm...';
  static const String productFilterTitle = 'Bộ lọc';
  static const String productFilterClearAll = 'Xóa tất cả';
  static const String productFilterReset = 'Đặt lại';
  static const String productFilterApply = 'Áp dụng';
  static const String productFilterCategory = 'Danh mục';
  static const String productFilterBrand = 'Thương hiệu';
  static const String productFilterGender = 'Giới tính';
  static const String productFilterColor = 'Màu sắc';
  static const String productFilterPriceRange = 'Khoảng giá';
  static const String productFilterAll = 'Tất cả';
  static const String productFilterMale = 'Nam';
  static const String productFilterFemale = 'Nữ';
  static const String productFilterUnisex = 'Unisex';
  static const String productFilterMinPrice = 'Từ';
  static const String productFilterMaxPrice = 'Đến';
  static const String productFilterCurrencySuffix = 'đ';
  static const String productFilterUnderOneMillion = 'Dưới 1.000.000đ';
  static const String productFilterOneToThreeMillion = '1 - 3 triệu';
  static const String productFilterCategoryLoadError =
      'Không tải được danh mục';
  static const String productFilterBrandLoadError =
      'Không tải được thương hiệu';
  static const String productSortNewest = 'Mới nhất';
  static const String productSortPriceAsc = 'Giá tăng dần';
  static const String productSortPriceDesc = 'Giá giảm dần';
  static const String productCatalogEmpty = 'Không tìm thấy sản phẩm';
  static const String productCatalogClearFilter = 'Xóa bộ lọc';
  static const String productHomeCategoriesTitle = 'Danh mục';
  static const String productHomeViewAll = 'XEM TẤT CẢ';
  static const String productHomeFeaturedTitle = 'Sản phẩm nổi bật';
  static const String productHomeFeaturedEmpty =
      'Không có sản phẩm nổi bật nào.';
  static const String productHomeLoadError = 'Đã xảy ra lỗi khi tải trang chủ.';
  static const String productHomeCategoryRunning = 'Giày Chạy';
  static const String productHomeCategoryApparel = 'Trang Phục';
  static const String productHomeCategoryAccessories = 'Phụ Kiện';
  static const String productHomeCategoryEquipment = 'Dụng Cụ';
  static const String productHomeHeroEyebrow = 'DÒNG SẢN PHẨM MỚI NHẤT';
  static const String productHomeHeroTitle = 'BỨT PHÁ GIỚI HẠN';
  static const String productHomeHeroSubtitle =
      'Trang bị đỉnh cao cho những vận động viên không ngừng vươn lên và chinh phục đỉnh cao mới.';
  static const String productHomeHeroCta = 'MUA SẮM NGAY';
  static const String productListCollectionEyebrow = 'BỘ SƯU TẬP SPORT PRO';
  static const String productListAllProducts = 'Tất cả sản phẩm';
  static const String productListBack = 'Trở về';
  static const String productListEmptySubtitle =
      'Không có sản phẩm nào phù hợp với bộ lọc đã chọn.';
  static const String productListLoadError = 'Đã xảy ra lỗi khi tải sản phẩm.';
  static const String productListFilterAndSort = 'Bộ lọc & Sắp xếp';
  static const String productListSortByPrice = 'SẮP XẾP THEO GIÁ';
  static const String productListSortNone = 'Không sắp xếp';
  static const String productListSortPriceLowToHigh = 'Giá từ thấp đến cao';
  static const String productListSortPriceHighToLow = 'Giá từ cao đến thấp';
  static const String productListCategoryRunning = 'Giày chạy bộ';
  static const String productListCategoryMen = 'Nam';
  static const String productListCategorySize42 = 'Size 42';
  static const String productListCategoryClothing = 'Quần áo';
  static String productFilterPriceBetween(String min, String max) =>
      '$min - $max';
  static String productFilterPriceFrom(String min) => 'Từ $min';
  static String productFilterPriceTo(String max) => 'Đến $max';

  // Customizer
  static const String customizerDefaultPrintMethod = 'In chuyển nhiệt';
  static const String customizerDefaultTextLayer = 'LỚP CHỮ MỚI';
  static const String customizerDefaultLayerText = 'SPORT PRO';
  static const String customizerDefaultTeamText = 'TEAM SPORT';
  static const String customizerDefaultTextColor = 'Jet Black';
  static const String customizerUploadImageError =
      'Không thể tải ảnh. Vui lòng kiểm tra quyền truy cập thư viện.';
  static const String customizerColorPickerTitle = 'Chọn màu sắc in';
  static const String customizerCaptureError = 'Không thể chụp hình thiết kế.';
  static const String customizerSaveSuccess =
      'Đã lưu thiết kế lên hệ thống thành công!';
  static const String customizerSyncError = 'Không thể đồng bộ với server.';
  static const String customizerLoading = 'Đang tải cấu hình in ấn...';
  static const String customizerLoadError = 'Không thể tải cấu hình in ấn.';
  static const String customizerSaving = 'Đang lưu thiết kế lên server...';
  static const String customizerTitle = 'TÙY CHỈNH THIẾT KẾ';
  static const String customizerPanelSubtitle =
      'Tự tay thiết kế áo thi đấu đẳng cấp cao. Tên, số áo và logo tùy chỉnh theo ý bạn.';
  static const String customizerMaterialSection = 'CHẤT LIỆU IN ẤN';
  static const String customizerTextEditorTitle = 'CHỈNH SỬA CHỮ / SỐ';
  static const String customizerAddLayer = 'THÊM LỚP MỚI';
  static const String customizerTextLayerContent = 'NỘI DUNG LỚP CHỮ';
  static const String customizerFont = 'FONT CHỮ';
  static const String customizerSportFontSuffix = 'Thể thao';
  static const String customizerPrintColor = 'MÀU SẮC IN';
  static const String customizerFontSize = 'CỠ CHỮ';
  static const String customizerNoTextLayerSelected =
      'Chọn hoặc thêm một lớp chữ để bắt đầu chỉnh sửa.';
  static const String customizerUploadLogoTitle = 'TẢI LÊN LOGO CỦA BẠN';
  static const String customizerUploadLogoAction = 'NHẤN ĐỂ TẢI ẢNH LÊN';
  static const String customizerUploadLogoHint = 'PNG, JPG, SVG (Tối đa 5MB)';
  static const String customizerTotalProduct = 'TỔNG CỘNG SẢN PHẨM';
  static const String customizerPrintingPriceLabel = 'Giá in thêm';
  static const String customizerPrintingPriceHint = '(Gồm phôi & lớp in)';
  static const String customizerSelectedColor = 'Selected Color';
  static String customizerSportFontLabel(String font) =>
      '$font ($customizerSportFontSuffix)';
  static String customizerPrintingPrice(String price) =>
      '$customizerPrintingPriceLabel: $price ₫';

  // Admin product - bulk variants
  static const String adminProductBulkTitle = 'Tạo nhanh biến thể';
  static const String adminProductBulkSizeGroupStep = '1. CHỌN NHÓM SIZE';
  static const String adminProductBulkSizeGroupHint = 'Chọn nhóm kích thước';
  static const String adminProductBulkSizeGroupRequired =
      'Vui lòng chọn nhóm size';
  static const String adminProductBulkSizeStep = '2. TÙY CHỌN KÍCH THƯỚC';
  static const String adminProductBulkColorStep = '3. CHỌN MÀU SẮC';
  static const String adminProductBulkDefaultsStep =
      '4. THÔNG SỐ BIẾN THỂ MẶC ĐỊNH';
  static const String adminProductBulkOriginalPrice = 'Giá gốc *';
  static const String adminProductBulkSalePrice = 'Giá sale';
  static const String adminProductBulkStock = 'Tồn kho *';
  static const String adminProductBulkRequired = 'Bắt buộc';
  static const String adminProductBulkInvalid = 'Không hợp lệ';
  static const String adminProductBulkInteger = 'Số nguyên';
  static const String adminProductBulkPreview = 'XEM TRƯỚC';
  static const String adminProductBulkRegenerate = 'Tạo lại tổ hợp';
  static const String adminProductBulkPreviewAction = 'Xem trước tổ hợp';
  static const String adminProductBulkEditVariant = 'Chỉnh sửa biến thể';
  static const String adminProductBulkConfirmSave = 'Xác nhận & Lưu';
  static String adminProductBulkVariantCount(int count) => '$count biến thể';
  static String adminProductBulkConfirmSaveCount(int count) =>
      '$adminProductBulkConfirmSave ($count)';

  // Admin product - variant form
  static const String adminProductVariantBasicInfoRequired =
      'Hoàn tất thông tin cơ bản ở Bước 1 trước khi thêm biến thể.';
  static const String adminProductVariantEmptyTitle = 'Chưa có biến thể nào';
  static const String adminProductVariantEmptyHint =
      'Nhấn "Thêm biến thể" để thêm mới';
  static const String adminProductVariantAddTitle = 'Thêm biến thể';
  static const String adminProductVariantColorLabel = 'Màu sắc *';
  static const String adminProductVariantColorRequired =
      'Vui lòng chọn màu sắc';
  static const String adminProductVariantSizeLabel = 'Kích thước *';
  static const String adminProductVariantSizeHint = 'S, M, L...';
  static const String adminProductVariantSkuLabel = 'SKU *';
  static const String adminProductVariantStatusLabel = 'Trạng thái';
  static const String adminProductVariantStatusActive = 'Đang bán';
  static const String adminProductVariantStatusInactive = 'Tạm ẩn';
  static const String adminProductVariantCreateBulk = 'Tạo hàng loạt';
  static const String adminProductVariantAddOne = 'Thêm 1 biến thể';
  static const String adminProductVariantBack = 'Quay lại';
  static const String adminProductVariantNext = 'Tiếp theo';
  static const String adminProductVariantAdd = 'Thêm';
  static const String adminProductVariantPriceSuffix = 'đ';
  static String adminProductVariantEditTitle(String sku) => 'Sửa: $sku';
  static String adminProductVariantStockUnit(int count) => '$count cái';
  static String adminProductVariantSubtitle({
    required String size,
    required String colorName,
    required String price,
    String? salePrice,
  }) =>
      salePrice == null
          ? '$size · $colorName · $price'
          : '$size · $colorName · $price (Sale: $salePrice)';

  // Admin product - detail
  static const String adminProductDetailTitle = 'Chi tiết sản phẩm';
  static const String adminProductDetailRetry = 'Thử lại';
  static const String adminProductDetailBrandLabel = 'Thương hiệu';
  static const String adminProductDetailCategoryLabel = 'Danh mục';
  static const String adminProductDetailGenderLabel = 'Giới tính';
  static const String adminProductDetailStatusLabel = 'Trạng thái';
  static const String adminProductDetailVariantsTitle = 'Biến thể';
  static const String adminProductDetailImagesTitle = 'Ảnh sản phẩm';
  static const String adminProductDetailUploadImage = 'Tải ảnh';
  static const String adminProductDetailUploadingImage = 'Đang tải ảnh...';
  static const String adminProductDetailNoImages = 'Chưa có ảnh nào';
  static const String adminProductDetailSkuLabel = 'SKU';
  static const String adminProductDetailStockLabel = 'Tồn';
  static String adminProductDetailLabel(String label, String value) =>
      '$label: $value';
  static String adminProductDetailVariantTitle(String size, String colorName) =>
      '$size — $colorName';
  static String adminProductDetailVariantSubtitle({
    required String sku,
    required int stock,
    required String price,
    String? salePrice,
  }) {
    final base =
        '$adminProductDetailSkuLabel: $sku • $adminProductDetailStockLabel: $stock • $price';
    return salePrice == null ? base : '$base (Sale: $salePrice)';
  }

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
  static const String shopFieldLogoUrlHint = 'Nhập đường dẫn ảnh logo cửa hàng';
  static const String shopFieldCoverUrl = 'URL Ảnh bìa';
  static const String shopFieldCoverUrlHint = 'Nhập đường dẫn ảnh bìa cửa hàng';

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

  // Admin size group management
  static const String adminSizeGroupTitle = 'Nhóm kích thước';
  static const String adminSizeGroupCreateTitle = 'Tạo nhóm kích thước';
  static const String adminSizeGroupEditTitle = 'Sửa nhóm kích thước';
  static const String adminSizeGroupEmpty = 'Chưa có nhóm kích thước nào';
  static const String adminSizeGroupCreateAction = 'Tạo mới';
  static const String adminSizeGroupCreated =
      'Đã tạo nhóm kích thước thành công!';
  static const String adminSizeGroupUpdated =
      'Đã cập nhật nhóm kích thước thành công!';
  static const String adminSizeGroupDeleted =
      'Đã xóa nhóm kích thước thành công!';
  static const String adminSizeGroupDeleteTitle = 'Xác nhận xóa';
  static String adminSizeGroupDeleteBody(String name) =>
      'Bạn có chắc muốn xóa nhóm kích thước "$name"?';
  static const String adminSizeGroupNameLabel = 'Tên nhóm kích thước *';
  static const String adminSizeGroupNameRequired = 'Vui lòng nhập tên';
  static const String adminSizeGroupDescriptionLabel = 'Mô tả (tùy chọn)';
  static const String adminSizeGroupSave = 'Lưu';
  static const String adminSizeGroupSizeListLabel = 'Danh sách kích thước';
  static const String adminSizeGroupAddSize = 'Thêm kích thước';
  static const String adminSizeGroupSizeNameHint = 'Tên size (vd: M, 42)';
  static const String adminSizeGroupSizeOrderHint = 'Thứ tự';

  // Admin color management
  static const String adminColorManagementTitle = 'Quản lý Màu sắc';
  static const String adminColorProductTab = 'Màu sản phẩm';
  static const String adminColorPrintingTab = 'Màu in ấn';
  static const String adminColorStatusActive = 'Active';
  static const String adminColorStatusDisabled = 'Disabled';

  // Color picker dialog
  static const String adminColorPickerTitle = 'Chọn màu sắc';
  static const String adminColorPickerDone = 'XONG';

  // Delete dialogs
  static const String adminColorDeleteProductTitle = 'Xóa màu sản phẩm?';
  static String adminColorDeleteProductBody(String name) =>
      'Bạn có chắc muốn xóa màu "$name" khỏi sản phẩm?';
  static const String adminColorDeletePrintingTitle = 'Xóa màu in ấn?';
  static String adminColorDeletePrintingBody(String name) =>
      'Bạn có chắc muốn xóa màu in ấn "$name"?';

  // Printing color form
  static const String adminColorPrintingFormEditTitle = 'Sửa màu in ấn';
  static const String adminColorPrintingFormCreateTitle = 'Thêm màu in ấn mới';
  static const String adminColorPrintingNameLabel = 'TÊN MÀU IN';
  static const String adminColorPrintingNameHint =
      'Nhập tên màu in (ví dụ: Gold Foil)';
  static const String adminColorHexLabel = 'MÃ HEX (HEX CODE)';
  static const String adminColorPrintingHexHint =
      'Nhập mã Hex (ví dụ: #D4AF37)';
  static const String adminColorPreviewLabel = 'Xem trước màu sắc';
  static const String adminColorPresetsLabel = 'MÀU ĐÃ CÓ SẴN (GỢI Ý)';
  static const String adminColorStatusLabel = 'TRẠNG THÁI HOẠT ĐỘNG';
  static const String adminColorPrintingNameRequired =
      'Vui lòng nhập tên màu in!';
  static const String adminColorHexInvalid = 'Mã HEX không hợp lệ!';
  static const String adminColorSaveChanges = 'LƯU THAY ĐỔI';
  static const String adminColorCreatePrintingAction = 'THÊM MÀU IN ẤN';

  // Product color form
  static const String adminColorProductFormEditTitle = 'Sửa màu sản phẩm';
  static const String adminColorProductFormCreateTitle =
      'Thêm màu sản phẩm mới';
  static const String adminColorProductNameLabel = 'TÊN MÀU SẮC';
  static const String adminColorProductNameHint =
      'Nhập tên màu (ví dụ: Aero Blue)';
  static const String adminColorProductHexHint = 'Nhập mã Hex (ví dụ: #FF6D00)';
  static const String adminColorProductNameRequired = 'Vui lòng nhập tên màu!';
  static const String adminColorHexInvalidFull =
      'Mã HEX không hợp lệ! Vui lòng bắt đầu với # và có 3 hoặc 6 ký tự số/chữ.';
  static const String adminColorCreateProductAction = 'THÊM MÀU SẢN PHẨM';

  // Color list empty / error states
  static const String adminColorProductEmpty = 'Chưa có màu sản phẩm nào.';
  static const String adminColorProductError = 'Lỗi tải màu sản phẩm.';
  static const String adminColorPrintingEmpty = 'Chưa có màu in ấn nào.';
  static const String adminColorPrintingError = 'Lỗi tải màu in ấn.';

  // Cubit success messages
  static const String adminColorPrintingCreated =
      'Đã thêm màu in ấn thành công!';
  static const String adminColorPrintingUpdated =
      'Đã cập nhật màu in ấn thành công!';
  static const String adminColorPrintingDeleted =
      'Đã xóa màu in ấn thành công!';
  static const String adminColorPrintingStatusUpdated =
      'Đã cập nhật trạng thái màu in!';
  static const String adminColorProductCreated =
      'Đã thêm màu sản phẩm thành công!';
  static const String adminColorProductUpdated =
      'Đã cập nhật màu sản phẩm thành công!';
  static const String adminColorProductDeleted =
      'Đã xóa màu sản phẩm thành công!';

  // Auth login/register screen strings
  static const String authTagline = 'Hiệu suất tối đa. Khởi đầu ngay.';
  static const String loginTitle = 'Đăng nhập';
  static const String loginSubmit = 'Đăng nhập';
  static const String registerTitle = 'Đăng ký';
  static const String emailLabel = 'EMAIL';
  static const String passwordLabel = 'MẬT KHẨU';
  static const String emailHint = 'vvd@example.com';
  static const String passwordHint = '••••••••';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String emailRequired = 'Vui lòng nhập email';
  static const String emailInvalid = 'Email không đúng định dạng';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static String passwordMinLength(int n) =>
      'Mật khẩu phải chứa ít nhất $n ký tự';

  // Terms & policy
  static const String termsPrefix = 'Bằng việc đăng nhập, bạn đồng ý với ';
  static const String termsOfService = 'Điều khoản dịch vụ';
  static const String andConnector = ' và ';
  static const String privacyPolicy = 'Chính sách bảo mật';
  static const String termsSuffix = ' của chúng tôi.';
}
