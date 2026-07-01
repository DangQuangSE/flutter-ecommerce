/// Centralized user-facing text. Never hardcode UI strings inline — add a
/// constant here instead, so swapping to a localization framework later
/// only touches this file.
abstract final class AppStrings {
  // Bottom navigation
  static const String navHome = 'Trang chủ';
  static const String navShop = 'Cửa hàng';
  static const String navOrders = 'Đơn hàng';
  static const String navProfile = 'Cá nhân';

  // Checkout
  static const String checkoutTitle = 'THANH TOÁN';
  static const String checkoutShippingSectionTitle = 'THÔNG TIN GIAO HÀNG';
  static const String checkoutPaymentSectionTitle = 'PHƯƠNG THỨC THANH TOÁN';
  static const String checkoutCouponSectionTitle = 'MÃ GIẢM GIÁ (COUPON)';
  static const String checkoutAddressRequired =
      'Vui lòng chọn địa chỉ giao hàng!';
  static const String checkoutShippingInfoRequired =
      'Vui lòng điền đầy đủ thông tin giao hàng!';
  static const String checkoutFullNameLabel = 'HỌ VÀ TÊN';
  static const String checkoutFullNameRequired = 'Vui lòng nhập họ và tên';
  static const String checkoutPhoneLabel = 'SỐ ĐIỆN THOẠI';
  static const String checkoutPhoneRequired = 'Vui lòng nhập số điện thoại';
  static const String checkoutPhoneInvalid =
      'Số điện thoại không hợp lệ (VD: 0912345678)';
  static const String checkoutShippingAddressLabel = 'ĐỊA CHỈ GIAO HÀNG';
  static const String checkoutShippingAddressRequired =
      'Vui lòng nhập địa chỉ giao hàng';
  static const String checkoutShippingEditHint =
      'Bạn có thể chỉnh sửa thông tin giao hàng bên dưới nếu cần.';

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
  static const String save = 'Lưu';
  static const String confirm = 'Xác nhận';
  static const String clearSearch = 'Xóa tìm kiếm';
  static const String genericLoadError = 'Đã xảy ra lỗi khi tải dữ liệu.';
  static const String networkConnectionError = 'Lỗi kết nối mạng';
  static const String viewCart = 'XEM GIỎ';
  static const String addToCart = 'ADD TO CART';
  static const String outOfStock = 'HẾT HÀNG';

  // Commerce common
  static const String checkoutEmptyTitle = 'ĐƠN HÀNG RỖNG';
  static const String checkoutEmptyMessage =
      'Không tìm thấy sản phẩm nào để thanh toán. Hãy quay về giỏ hàng hoặc tiếp tục mua sắm nhé!';
  static const String checkoutBackToShopping = 'QUAY LẠI MUA SẮM';
  static const String checkoutLoadErrorTitle =
      'Không thể tải thông tin thanh toán.';
  static const String checkoutRetry = 'Thử lại';
  static const String checkoutSubtotalLabel = 'Tạm tính';
  static const String checkoutProductCountSuffix = 'sản phẩm';
  static const String checkoutVoucherDiscountLabel = 'Giảm giá (Voucher)';
  static const String checkoutExpressShippingLabel = 'Giao hàng hỏa tốc';
  static const String checkoutFreeShipping = 'Miễn phí';
  static const String checkoutGrandTotalLabel = 'TỔNG CỘNG';
  static const String checkoutCouponPickerTitle = 'Chọn Sport Pro Voucher';
  static const String checkoutCouponInvalid =
      'Mã giảm giá không hợp lệ hoặc đã hết hạn';
  static const String checkoutCouponMinOrderNotMet =
      'Đơn hàng chưa đạt giá trị tối thiểu';
  static const String checkoutCouponAvailableSection = 'MÃ GIẢM GIÁ KHẢ DỤNG';
  static const String checkoutCouponUnavailableSection = 'MÃ KHÔNG KHẢ DỤNG';
  static const String checkoutCouponEmpty = 'Không có mã giảm giá nào';
  static const String checkoutNoAddressTitle = 'CHƯA CÓ ĐỊA CHỈ GIAO HÀNG';
  static const String checkoutNoAddressMessage =
      'Thêm địa chỉ giao hàng để tiến hành đặt hàng.';
  static const String checkoutAddAddress = 'THÊM ĐỊA CHỈ';
  static const String checkoutAddNewAddress = 'THÊM ĐỊA CHỈ MỚI';
  static const String checkoutDefaultAddress = 'MẶC ĐỊNH';
  static const String checkoutChangeAddress = 'THAY ĐỔI';
  static const String checkoutSelectAddressTitle = 'CHỌN ĐỊA CHỈ GIAO HÀNG';
  static const String checkoutVoucherTitle = 'Sport Pro Voucher';
  static String checkoutCouponApplied(String code) => 'Đã áp dụng mã: $code';
  static String checkoutCouponSaved(String amount) => 'Tiết kiệm được $amount';
  static const String checkoutCouponLoadError =
      'Không tải được mã giảm giá. Nhấn để thử lại.';
  static const String checkoutCouponLoading = 'Đang tải mã giảm giá...';
  static const String checkoutCouponChooseOrEnter =
      'Chọn hoặc nhập mã giảm giá';
  static const String ok = 'OK';
  static const String paymentVnpayTitle = 'VNPay';
  static const String paymentCancelTitle = 'Hủy thanh toán?';
  static const String paymentCancelMessage =
      'Bạn có chắc muốn hủy thanh toán VNPay? Đơn hàng vẫn ở trạng thái chờ thanh toán.';
  static const String paymentContinue = 'Tiếp tục';
  static const String paymentCancel = 'Hủy';
  static const String paymentSuccessTitle = 'Thanh toán thành công';
  static const String paymentFailureTitle = 'Thanh toán thất bại';
  static const String paymentBackHome = 'VỀ TRANG CHỦ';
  static const String notificationTitle = 'Thông báo';
  static const String notificationEmptyTitle = 'KHÔNG CÓ THÔNG BÁO';
  static const String notificationEmptyMessage =
      'Hộp thư của bạn hiện đang trống. Mọi cập nhật về đơn hàng hoặc ưu đãi đặc biệt sẽ xuất hiện tại đây!';
  static const String notificationLatestSection = 'MỚI NHẤT';
  static const String notificationOlderSection = 'TRƯỚC ĐÓ';
  static const String notificationMarkAllRead = 'Đánh dấu đã đọc';
  static const String notificationMarkAllReadSuccess =
      'Đã đánh dấu đọc tất cả thông báo.';
  static const String notificationNoUnread =
      'Không có thông báo chưa đọc mới nào.';
  static const String notificationLoadErrorTitle =
      'Đã xảy ra lỗi khi tải danh sách thông báo.';
  static const String profileLoadingName = 'Đang tải…';
  static const String profileDefaultName = 'Người dùng';
  static const String profileLoadError = 'Không tải được hồ sơ';
  static const String profileAccountSection = 'TÀI KHOẢN VÀ BẢO MẬT';
  static const String profileSettingsSection = 'THIẾT LẬP VÀ TIN NHẮN';
  static const String profilePersonalInfo = 'Thông tin cá nhân';
  static const String profileMyOrders = 'Đơn hàng của tôi';
  static const String profileShippingAddresses = 'Địa chỉ giao hàng';
  static const String profilePaymentMethods = 'Phương thức thanh toán';
  static const String profileAppNotifications = 'Thông báo ứng dụng';
  static const String profileInbox = 'Hộp thư tin nhắn';
  static const String profileSystemSettings = 'Cài đặt hệ thống';
  static const String profileLogout = 'Đăng xuất';
  static const String profileLogoutConfirm = 'Bạn có chắc muốn đăng xuất?';
  static String profileTier(String tier) => 'HẠNG ${tier.toUpperCase()}';
  static const String editProfileAvatarUpdated = 'Đã cập nhật ảnh đại diện';
  static const String editProfileSaved = 'Đã lưu thay đổi';
  static const String editProfileFirstNameLabel = 'TÊN';
  static const String editProfileLastNameLabel = 'HỌ';
  static const String editProfileEmailLabel = 'EMAIL';
  static const String editProfileFirstNameHint = 'Tên';
  static const String editProfileLastNameHint = 'Họ';
  static const String editProfileFirstNameRequired = 'Vui lòng nhập tên';
  static const String editProfileLastNameRequired = 'Vui lòng nhập họ';
  static const String editProfileSaveChanges = 'LƯU THAY ĐỔI';
  static const String chatListTitle = 'Hộp thư thoại';
  static const String chatHotlineMessage = 'Hotline CSKH: 1900-SPORT-PRO';
  static const String chatAttachmentMessage = 'Tải lên ảnh đính kèm.';
  static const String chatMessageHint = 'Nhập tin nhắn...';
  static const String chatDefaultSupportName = 'Hỗ trợ khách hàng';
  static const String chatEscalationMessage =
      'Yêu cầu hỗ trợ đã được chuyển tiếp đến giám sát viên.';
  static const String chatOnline = 'Đang hoạt động';
  static const String chatOffline = 'Ngoại tuyến';
  static const String appDisplayName = 'Flutter E-Commerce';
  static const String googleSignInSetup =
      'Đăng nhập bằng Google đang được thiết lập';
  static const String registerSuccessLoginPrompt =
      'Đăng ký thành công! Vui lòng đăng nhập.';
  static const String forgotPasswordResetSuccess =
      'Đặt lại mật khẩu thành công. Vui lòng đăng nhập.';
  static const String otpResent = 'Mã OTP đã được gửi lại';
  static const String otpVerifyEmailTitle = 'Xác minh email';
  static String otpSentToEmail(String email) =>
      'Nhập mã 6 số đã gửi tới $email';
  static const String otpConfirm = 'Xác nhận';
  static String otpResendCountdown(int seconds) => 'Gửi lại sau ${seconds}s';
  static const String otpResendCode = 'Gửi lại mã OTP';
  static const String forgotPasswordOtpTitle = 'Nhập mã OTP';
  static const String forgotPasswordOtpHelp =
      'Nếu bạn không nhận được mã, kiểm tra email hoặc quay lại.';
  static const String forgotPasswordResendShort = 'Gửi lại mã';
  static const String forgotPasswordBackToEmail = 'Quay lại nhập email';
  static const String cartTitle = 'GIỎ HÀNG';
  static const String cartListTitle = 'DANH SÁCH GIỎ HÀNG';
  static String cartSelectAll(int selected, int total) =>
      'CHỌN TẤT CẢ ($selected/$total)';
  static const String cartRemoveItemTitle = 'Xóa sản phẩm?';
  static String cartRemoveItemMessage(String name) =>
      'Bạn có chắc chắn muốn xóa $name khỏi giỏ hàng?';
  static const String cartRemoveItemConfirm = 'XÓA BỎ';
  static const String cartRemoveDesignTitle = 'Xóa thiết kế in ấn?';
  static String cartRemoveDesignMessage(String name) =>
      'Bạn có chắc muốn xóa thiết kế in ấn khỏi sản phẩm $name? Thiết kế của bạn sẽ bị hủy và sản phẩm được trả về dạng nguyên bản.';
  static const String cartRemoveDesignConfirm = 'XÓA THIẾT KẾ';
  static const String customDesignSpecUnavailable = 'N/A';
  static const String customDesignSpecMaterialLabel = 'Chất liệu tuyển chọn:';
  static const String customDesignSpecTextLinesLabel = 'Số lớp chữ in thêm:';
  static const String customDesignSpecImagesLabel = 'Số logo tải lên:';
  static const String customDesignSpecTotalLabel = 'Tổng cộng chi phí in:';
  static String customDesignSpecTextLines(int count) => '$count lớp';
  static String customDesignSpecImages(int count) => '$count ảnh';
  static String customDesignSpecPricingFormula(
    String textUnitPrice,
    String imageUnitPrice,
  ) =>
      'Công thức tính giá in ấn: Giá phôi in + (Số lớp chữ x $textUnitPrice/lớp) + (Số logo x $imageUnitPrice/ảnh)';

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

  // Admin product - pages
  static const String adminProductListTitle = 'Quản lý sản phẩm';
  static const String adminProductListEmpty = 'Không có sản phẩm nào';
  static const String adminProductDeleteTitle = 'Xác nhận xóa';
  static String adminProductDeleteMessage(String name) =>
      'Xóa sản phẩm "$name"?';
  static const String adminProductCreateTitle = 'Thêm sản phẩm mới';
  static const String adminProductEditTitle = 'Chỉnh sửa sản phẩm';
  static const String adminProductCreated = 'Tạo sản phẩm thành công';
  static const String adminProductUpdated = 'Cập nhật sản phẩm thành công';
  static const String adminProductBasicInfoSaved = 'Đã lưu thông tin cơ bản';
  static const String adminProductDropdownLoadError =
      'Không thể tải danh sách.';
  static const String adminProductAbandonTitle = 'Rời khỏi form?';
  static const String adminProductAbandonMessage =
      'Sản phẩm đã được tạo nhưng chưa hoàn tất.\nXóa sản phẩm này và thoát?';
  static const String adminProductContinueEditing = 'Tiếp tục chỉnh sửa';
  static const String adminProductDeleteAndExit = 'Xóa & thoát';
  static const String adminProductManualDeleteWarning =
      'Không thể xóa sản phẩm. Vui lòng xóa thủ công từ danh sách.';

  // Admin product - image form
  static const String adminProductImagesAdd = 'Thêm ảnh';
  static const String adminProductImagesThumbnail = 'Thumb';
  static const String adminProductImagesBack = 'Quay lại';
  static const String adminProductImagesComplete = 'Hoàn tất';
  static const String adminProductImagesBasicInfoRequired =
      'Hoàn tất thông tin cơ bản ở Bước 1 trước khi thêm ảnh.';
  static String adminProductImagesTitle(int count, int max) =>
      'Hình ảnh sản phẩm ($count/$max)';
  static String adminProductImagesUploadLimit(int remaining, int max) =>
      'Chỉ tải lên $remaining ảnh còn lại (giới hạn $max ảnh)';

  // Admin catalog common
  static const String adminCatalogAdd = 'Thêm';
  static const String adminBrandSearchHint = 'Tìm kiếm thương hiệu...';
  static const String adminBrandEmptyTitle = 'Không tìm thấy thương hiệu nào';
  static const String adminBrandLoadFallback =
      'Đã xảy ra lỗi khi tải thương hiệu.';
  static const String adminBrandDeleteTitle = 'Xóa thương hiệu?';
  static String adminBrandDeleteMessage(String name) =>
      'Bạn có chắc chắn muốn xóa thương hiệu "$name"? Hành động này không thể hoàn tác.';
  static const String adminBrandNameLabel = 'TÊN THƯƠNG HIỆU';
  static const String adminBrandNameHint = 'Nhập tên thương hiệu (ví dụ: Nike)';
  static const String adminBrandNameInvalid =
      'Tên thương hiệu phải từ 2 đến 100 ký tự!';
  static const String adminBrandCountryLabel = 'QUỐC GIA';
  static const String adminBrandCountryHint = 'Ví dụ: USA, Vietnam';
  static const String adminBrandWebsiteLabel = 'WEBSITE';
  static const String adminBrandWebsiteHint = 'Ví dụ: https://www.nike.com';
  static const String adminBrandLogoLabel = 'LOGO URL';
  static const String adminBrandLogoHint = 'Nhập URL hình ảnh logo';
  static const String adminBrandDescriptionLabel = 'MÔ TẢ';
  static const String adminBrandDescriptionHint =
      'Nhập mô tả về thương hiệu...';
  static const String adminBrandActiveStatusLabel = 'TRẠNG THÁI HOẠT ĐỘNG';
  static const String adminBrandFormEditTitle = 'Chỉnh sửa thương hiệu';
  static const String adminBrandFormCreateTitle = 'Thêm thương hiệu mới';
  static const String adminBrandSaveChanges = 'LƯU THAY ĐỔI';
  static const String adminBrandCreateAction = 'THÊM THƯƠNG HIỆU';
  static const String adminCategorySearchHint = 'Tìm danh mục...';
  static const String adminCategoryManagementTitle = 'Quản lý danh mục';
  static const String adminCategoryViewTree = 'Xem cây danh mục';
  static const String adminCategoryEmptyTitle = 'Chưa có danh mục nào';
  static const String adminCategoryEmptyMessage =
      'Nhấn "Thêm" để tạo danh mục đầu tiên.';
  static const String adminCategoryLoadErrorTitle = 'Không tải được danh mục';
  static const String adminCategoryDeleted = 'Đã xóa danh mục';
  static const String adminCategoryCreated = 'Đã tạo danh mục';
  static const String adminCategoryUpdated = 'Đã cập nhật danh mục';
  static const String adminCategoryDeleteTitle = 'Xóa danh mục';
  static String adminCategoryDeleteMessage(String name) =>
      'Bạn có chắc muốn xóa "$name"?';
  static const String adminCategoryTreeTitle = 'Cây danh mục';
  static const String adminCategoryTreeEmpty = 'Không có dữ liệu.';
  static String adminCategoryCount(int count) => '$count danh mục';
  static const String adminCouponSearchHint = 'Tìm theo mã giảm giá...';
  static const String adminCouponEmptyTitle = 'Chưa có mã giảm giá nào';
  static const String adminCouponEmptyMessage =
      'Nhấn "Thêm" để tạo mã đầu tiên.';
  static const String adminCouponAdd = 'Thêm mã';
  static const String adminCouponLoadErrorTitle = 'Không tải được mã giảm giá';
  static const String adminCouponDeleteTitle = 'Xóa mã giảm giá';
  static const String adminCouponDeleted = 'Đã xóa mã giảm giá';
  static String adminCouponDeleteMessage(String code) =>
      'Bạn có chắc muốn xóa mã "$code"?';
  static const String adminCouponCreated = 'Đã tạo mã giảm giá';
  static const String adminCouponUpdated = 'Đã cập nhật mã giảm giá';
  static const String adminCouponEndDateAfterStart =
      'Ngày kết thúc phải sau ngày bắt đầu';
  static const String adminCouponCreateSubmit = 'Tạo mã giảm giá';
  static const String adminCouponSaveSubmit = 'Lưu thay đổi';
  static String adminCouponTotalCount(int count) => '$count mã giảm giá';
  static String adminCouponFilteredCount(int filtered, int total) =>
      '$filtered/$total mã';
  static String adminCouponNoMatches(String query) =>
      'Không có mã nào khớp "$query".';
  static String adminCouponUsedWithLimit(int used, int limit) =>
      'Đã dùng $used/$limit';
  static String adminCouponUsed(int used) => 'Đã dùng $used';
  static String adminCouponExpires(String date) => 'HSD $date';
  static const String adminCouponExpired = 'Hết hạn';
  static const String adminCouponUsedUp = 'Hết lượt';

  // Admin product - basic info form
  static const String adminProductBasicNameLabel = 'Tên sản phẩm *';
  static const String adminProductBasicNameRequired =
      'Vui lòng nhập tên sản phẩm';
  static const String adminProductBasicDescriptionLabel = 'Mô tả';
  static const String adminProductBasicCategoryLabel = 'Danh mục *';
  static const String adminProductBasicCategoryRequired =
      'Vui lòng chọn danh mục';
  static const String adminProductBasicBrandLabel = 'Thương hiệu *';
  static const String adminProductBasicBrandRequired =
      'Vui lòng chọn thương hiệu';
  static const String adminProductBasicSizeGroupLabel = 'Nhóm kích thước';
  static const String adminProductBasicNoSizeGroup = 'Không có nhóm kích thước';
  static const String adminProductBasicGenderLabel = 'Giới tính *';
  static const String adminProductBasicGenderRequired =
      'Vui lòng chọn giới tính';
  static const String adminProductBasicGenderMale = 'Nam';
  static const String adminProductBasicGenderFemale = 'Nữ';
  static const String adminProductBasicGenderUnisex = 'Unisex';
  static const String adminProductBasicStatusLabel = 'Trạng thái';
  static const String adminProductBasicFeaturedTitle = 'Nổi bật';
  static const String adminProductBasicFeaturedSubtitle =
      'Hiển thị trên trang chủ';
  static const String adminProductBasicNext = 'Tiếp theo';
  static const String adminProductCategoryDepthPrefix = '—';

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
  static String productReviewCount(int count) => '($count)';
  static String reviewImageCounter(int current, int total) =>
      '$current / $total';

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
  static const String writeReviewSubmitError = 'Lỗi gửi đánh giá';
  static const String reviewListParseError =
      'Phản hồi danh sách đánh giá không hợp lệ';
  static const String reviewParseError = 'Phản hồi đánh giá không hợp lệ';
  static const String writeReviewParseError =
      'Phản hồi gửi đánh giá không hợp lệ';
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
  static const String addressContactSectionTitle = 'Thông tin người nhận';
  static const String addressFullNameLabel = 'Họ và tên';
  static const String addressPhoneLabel = 'Số điện thoại';
  static const String addressPhoneInvalid =
      'Số điện thoại không hợp lệ (VD: 0912345678)';
  static const String addressShippingSectionTitle = 'Địa chỉ giao hàng';
  static const String addressLineLabel = 'Số nhà, tên đường';
  static const String addressProvinceLabel = 'Tỉnh / Thành phố';
  static const String addressDistrictLabel = 'Quận / Huyện';
  static const String addressWardLabel = 'Phường / Xã';
  static const String addressProvincePickerHint = 'Chọn tỉnh/thành phố';
  static const String addressDistrictPickerHint = 'Chọn quận/huyện';
  static const String addressWardPickerHint = 'Chọn phường/xã';
  static const String addressProvincePickerRequired =
      'Vui lòng chọn tỉnh/thành phố';
  static const String addressDistrictPickerRequired =
      'Vui lòng chọn quận/huyện';
  static const String addressWardPickerRequired = 'Vui lòng chọn phường/xã';
  static const String addressOptionsSectionTitle = 'Tuỳ chọn';
  static const String addressLabelLabel = 'Nhãn địa chỉ';
  static const String addressOptionalLabelExample = 'Ví dụ: Nhà, Công ty...';
  static const String addressDefaultOrderHint =
      'Dùng địa chỉ này mặc định khi đặt hàng';

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
  static const String loginOrDivider = 'Hoặc';
  static const String googleLogoLetter = 'G';
  static const String googleBrandName = 'Google';
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

  // Admin dashboard
  static const String adminDashboardLoadError =
      'Đã xảy ra lỗi khi tải dữ liệu Admin.';
  static const String adminNavOverview = 'Tổng quan';
  static const String adminNavManagement = 'Quản lý';
  static const String adminNavOrders = 'Đơn hàng';
  static const String adminNavStore = 'Cửa hàng';
  static const String adminNavProfile = 'Cá nhân';

  // Admin order management
  static const String adminOrderManagementTitle = 'Quản lý đơn hàng';
  static const String adminOrderSearchHint = 'Tìm mã đơn, SĐT...';
  static const String adminOrderDateRangeAll = 'Tất cả ngày';
  static const String adminOrderDateRangeAction = 'Lọc ngày';
  static const String adminOrderDateRangeClear = 'Xóa lọc ngày';
  static const String adminOrderEmpty = 'Không có đơn hàng nào.';
  static const String adminOrderDetailTitle = 'Chi tiết đơn hàng';
  static const String adminOrderStatusUpdated =
      'Đã cập nhật trạng thái đơn hàng!';
  static const String adminOrderSelectStatus = 'Chọn trạng thái mới';
  static const String adminOrderUpdating = 'Đang cập nhật...';
  static const String adminOrderUpdateStatus = 'Cập nhật trạng thái';
  static String adminOrderStatusChangeConfirm(String status) =>
      'Đổi trạng thái sang "$status"?';
  static const String filterAll = 'Tất cả';

  // Admin management tab
  static const String adminManagementTitle = 'Quản lý';
  static const String adminManagementSubtitle =
      'Truy cập nhanh các mục quản trị';
  static const String adminManageProducts = 'Quản lý Sản phẩm';
  static const String adminManageBrands = 'Quản lý Thương hiệu';
  static const String adminManageColors = 'Quản lý Màu sắc';
  static const String adminManageCategories = 'Quản lý Danh mục';
  static const String adminManageCoupons = 'Quản lý Mã giảm giá';
  static const String adminManageSizes = 'Quản lý Kích thước';
  static const String adminSupportMessages = 'Tin nhắn hỗ trợ';
  static const String adminReturnPolicy = 'Chính sách đổi trả & bảo hành';

  // Category form
  static const String categoryNameLabel = 'Tên danh mục *';
  static const String categoryNameHint = 'VD: Giày chạy bộ';
  static const String categoryNameRequired = 'Vui lòng nhập tên';
  static const String categoryNameMinLength = 'Tên tối thiểu 2 ký tự';
  static const String categoryDescriptionLabel = 'Mô tả';
  static const String categoryDescriptionHint = 'Mô tả ngắn về danh mục';
  static const String categoryParentLabel = 'Danh mục cha';
  static const String categoryParentNone = 'Không có (danh mục gốc)';
  static const String categoryImageLabel = 'Ảnh (URL)';
  static const String categoryImageHint = 'https://...';
  static const String categoryDisplayOrderLabel = 'Thứ tự hiển thị';
  static const String categoryDisplayOrderHint = 'VD: 1';
  static const String categoryStatusActiveTitle = 'Đang hoạt động';
  static const String categoryStatusActiveSubtitle =
      'Hiển thị danh mục cho khách hàng';
  static const String categoryCustomizableTitle = 'Cho phép tùy chỉnh';
  static const String categoryCustomizableSubtitle =
      'Sản phẩm trong danh mục có thể tùy biến';

  // Chat filters
  static const String chatSearchHint = 'Tìm kiếm cuộc hội thoại...';
  static const String chatFilterAll = 'Tất cả';
  static const String chatFilterUnread = 'Chưa đọc';
  static const String chatFilterSupport = 'Hỗ trợ';
}
