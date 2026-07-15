/// Admin feature strings — covers all admin screens.
abstract final class AdminStrings {
  // Admin product - bulk variants
  static const String productBulkTitle = 'Tạo nhanh biến thể';
  static const String productBulkSizeGroupStep = '1. CHỌN NHÓM SIZE';
  static const String productBulkSizeGroupHint = 'Chọn nhóm kích thước';
  static const String productBulkSizeGroupRequired =
      'Vui lòng chọn nhóm size';
  static const String productBulkSizeStep = '2. TÙY CHỌN KÍCH THƯỚC';
  static const String productBulkColorStep = '3. CHỌN MÀU SẮC';
  static const String productBulkDefaultsStep =
      '4. THÔNG SỐ BIẾN THỂ MẶC ĐỊNH';
  static const String productBulkOriginalPrice = 'Giá gốc *';
  static const String productBulkSalePrice = 'Giá sale';
  static const String productBulkStock = 'Tồn kho *';
  static const String productBulkRequired = 'Bắt buộc';
  static const String productBulkInvalid = 'Không hợp lệ';
  static const String productBulkInteger = 'Số nguyên';
  static const String productBulkPreview = 'XEM TRƯỚC';
  static const String productBulkRegenerate = 'Tạo lại tổ hợp';
  static const String productBulkPreviewAction = 'Xem trước tổ hợp';
  static const String productBulkEditVariant = 'Chỉnh sửa biến thể';
  static const String productBulkConfirmSave = 'Xác nhận & Lưu';
  static String productBulkVariantCount(int count) => '$count biến thể';
  static String productBulkConfirmSaveCount(int count) =>
      '$productBulkConfirmSave ($count)';

  // Admin product - variant form
  static const String productVariantBasicInfoRequired =
      'Hoàn tất thông tin cơ bản ở Bước 1 trước khi thêm biến thể.';
  static const String productVariantEmptyTitle = 'Chưa có biến thể nào';
  static const String productVariantEmptyHint =
      'Nhấn "Thêm biến thể" để thêm mới';
  static const String productVariantAddTitle = 'Thêm biến thể';
  static const String productVariantColorLabel = 'Màu sắc *';
  static const String productVariantColorRequired = 'Vui lòng chọn màu sắc';
  static const String productVariantSizeLabel = 'Kích thước *';
  static const String productVariantSizeHint = 'S, M, L...';
  static const String productVariantSkuLabel = 'SKU *';
  static const String productVariantStatusLabel = 'Trạng thái';
  static const String productVariantStatusActive = 'Đang bán';
  static const String productVariantStatusInactive = 'Tạm ẩn';
  static const String productVariantCreateBulk = 'Tạo hàng loạt';
  static const String productVariantAddOne = 'Thêm 1 biến thể';
  static const String productVariantBack = 'Quay lại';
  static const String productVariantNext = 'Tiếp theo';
  static const String productVariantAdd = 'Thêm';
  static const String productVariantPriceSuffix = 'đ';
  static String productVariantEditTitle(String sku) => 'Sửa: $sku';
  static String productVariantStockUnit(int count) => '$count cái';
  static String productVariantSubtitle({
    required String size,
    required String colorName,
    required String price,
    String? salePrice,
  }) =>
      salePrice == null
          ? '$size · $colorName · $price'
          : '$size · $colorName · $price (Sale: $salePrice)';

  // Admin product - detail
  static const String productDetailTitle = 'Chi tiết sản phẩm';
  static const String productDetailRetry = 'Thử lại';
  static const String productDetailBrandLabel = 'Thương hiệu';
  static const String productDetailCategoryLabel = 'Danh mục';
  static const String productDetailGenderLabel = 'Giới tính';
  static const String productDetailStatusLabel = 'Trạng thái';
  static const String productDetailVariantsTitle = 'Biến thể';
  static const String productDetailImagesTitle = 'Ảnh sản phẩm';
  static const String productDetailUploadImage = 'Tải ảnh';
  static const String productDetailUploadingImage = 'Đang tải ảnh...';
  static const String productDetailNoImages = 'Chưa có ảnh nào';
  static const String productDetailSkuLabel = 'SKU';
  static const String productDetailStockLabel = 'Tồn';
  static String productDetailLabel(String label, String value) =>
      '$label: $value';
  static String productDetailVariantTitle(String size, String colorName) =>
      '$size — $colorName';
  static String productDetailVariantSubtitle({
    required String sku,
    required int stock,
    required String price,
    String? salePrice,
  }) {
    final base =
        '$productDetailSkuLabel: $sku • $productDetailStockLabel: $stock • $price';
    return salePrice == null ? base : '$base (Sale: $salePrice)';
  }

  // Admin product - pages
  static const String productListTitle = 'Quản lý sản phẩm';
  static const String productListEmpty = 'Không có sản phẩm nào';
  static const String productDeleteTitle = 'Xác nhận xóa';
  static String productDeleteMessage(String name) => 'Xóa sản phẩm "$name"?';
  static const String productCreateTitle = 'Thêm sản phẩm mới';
  static const String productEditTitle = 'Chỉnh sửa sản phẩm';
  static const String productCreated = 'Tạo sản phẩm thành công';
  static const String productUpdated = 'Cập nhật sản phẩm thành công';
  static const String productBasicInfoSaved = 'Đã lưu thông tin cơ bản';
  static const String productDropdownLoadError = 'Không thể tải danh sách.';
  static const String productAbandonTitle = 'Rời khỏi form?';
  static const String productAbandonMessage =
      'Sản phẩm đã được tạo nhưng chưa hoàn tất.\nXóa sản phẩm này và thoát?';
  static const String productContinueEditing = 'Tiếp tục chỉnh sửa';
  static const String productDeleteAndExit = 'Xóa & thoát';
  static const String productManualDeleteWarning =
      'Không thể xóa sản phẩm. Vui lòng xóa thủ công từ danh sách.';

  // Admin product - image form
  static const String productImagesAdd = 'Thêm ảnh';
  static const String productImagesThumbnail = 'Thumb';
  static const String productImagesBack = 'Quay lại';
  static const String productImagesComplete = 'Hoàn tất';
  static const String productImagesBasicInfoRequired =
      'Hoàn tất thông tin cơ bản ở Bước 1 trước khi thêm ảnh.';
  static String productImagesTitle(int count, int max) =>
      'Hình ảnh sản phẩm ($count/$max)';
  static String productImagesUploadLimit(int remaining, int max) =>
      'Chỉ tải lên $remaining ảnh còn lại (giới hạn $max ảnh)';

  // Admin catalog common
  static const String catalogAdd = 'Thêm';

  // Brand management
  static const String brandSearchHint = 'Tìm kiếm thương hiệu...';
  static const String brandEmptyTitle = 'Không tìm thấy thương hiệu nào';
  static const String brandLoadFallback = 'Đã xảy ra lỗi khi tải thương hiệu.';
  static const String brandDeleteTitle = 'Xóa thương hiệu?';
  static String brandDeleteMessage(String name) =>
      'Bạn có chắc chắn muốn xóa thương hiệu "$name"? Hành động này không thể hoàn tác.';
  static const String brandNameLabel = 'TÊN THƯƠNG HIỆU';
  static const String brandNameHint = 'Nhập tên thương hiệu (ví dụ: Nike)';
  static const String brandNameInvalid = 'Tên thương hiệu phải từ 2 đến 100 ký tự!';
  static const String brandCountryLabel = 'QUỐC GIA';
  static const String brandCountryHint = 'Ví dụ: USA, Vietnam';
  static const String brandWebsiteLabel = 'WEBSITE';
  static const String brandWebsiteHint = 'Ví dụ: https://www.nike.com';
  static const String brandLogoLabel = 'LOGO URL';
  static const String brandLogoHint = 'Nhập URL hình ảnh logo';
  static const String brandDescriptionLabel = 'MÔ TẢ';
  static const String brandDescriptionHint = 'Nhập mô tả về thương hiệu...';
  static const String brandActiveStatusLabel = 'TRẠNG THÁI HOẠT ĐỘNG';
  static const String brandFormEditTitle = 'Chỉnh sửa thương hiệu';
  static const String brandFormCreateTitle = 'Thêm thương hiệu mới';
  static const String brandSaveChanges = 'LƯU THAY ĐỔI';
  static const String brandCreateAction = 'THÊM THƯƠNG HIỆU';

  // Category management
  static const String categorySearchHint = 'Tìm danh mục...';
  static const String categoryManagementTitle = 'Quản lý danh mục';
  static const String categoryViewTree = 'Xem cây danh mục';
  static const String categoryEmptyTitle = 'Chưa có danh mục nào';
  static const String categoryEmptyMessage =
      'Nhấn "Thêm" để tạo danh mục đầu tiên.';
  static const String categoryLoadErrorTitle = 'Không tải được danh mục';
  static const String categoryDeleted = 'Đã xóa danh mục';
  static const String categoryCreated = 'Đã tạo danh mục';
  static const String categoryUpdated = 'Đã cập nhật danh mục';
  static const String categoryDeleteTitle = 'Xóa danh mục';
  static String categoryDeleteMessage(String name) =>
      'Bạn có chắc muốn xóa "$name"?';
  static const String categoryTreeTitle = 'Cây danh mục';
  static const String categoryTreeEmpty = 'Không có dữ liệu.';
  static String categoryCount(int count) => '$count danh mục';

  // Coupon management
  static const String couponSearchHint = 'Tìm theo mã giảm giá...';
  static const String couponEmptyTitle = 'Chưa có mã giảm giá nào';
  static const String couponEmptyMessage = 'Nhấn "Thêm" để tạo mã đầu tiên.';
  static const String couponAdd = 'Thêm mã';
  static const String couponLoadErrorTitle = 'Không tải được mã giảm giá';
  static const String couponDeleteTitle = 'Xóa mã giảm giá';
  static const String couponDeleted = 'Đã xóa mã giảm giá';
  static String couponDeleteMessage(String code) =>
      'Bạn có chắc muốn xóa mã "$code"?';
  static const String couponCreated = 'Đã tạo mã giảm giá';
  static const String couponUpdated = 'Đã cập nhật mã giảm giá';
  static const String couponEndDateAfterStart =
      'Ngày kết thúc phải sau ngày bắt đầu';
  static const String couponCreateSubmit = 'Tạo mã giảm giá';
  static const String couponSaveSubmit = 'Lưu thay đổi';
  static String couponTotalCount(int count) => '$count mã giảm giá';
  static String couponFilteredCount(int filtered, int total) =>
      '$filtered/$total mã';
  static String couponNoMatches(String query) => 'Không có mã nào khớp "$query".';
  static String couponUsedWithLimit(int used, int limit) =>
      'Đã dùng $used/$limit';
  static String couponUsed(int used) => 'Đã dùng $used';
  static String couponExpires(String date) => 'HSD $date';
  static const String couponExpired = 'Hết hạn';
  static const String couponUsedUp = 'Hết lượt';

  // Admin product - basic info form
  static const String productBasicNameLabel = 'Tên sản phẩm *';
  static const String productBasicNameRequired = 'Vui lòng nhập tên sản phẩm';
  static const String productBasicDescriptionLabel = 'Mô tả';
  static const String productBasicCategoryLabel = 'Danh mục *';
  static const String productBasicCategoryRequired = 'Vui lòng chọn danh mục';
  static const String productBasicBrandLabel = 'Thương hiệu *';
  static const String productBasicBrandRequired = 'Vui lòng chọn thương hiệu';
  static const String productBasicSizeGroupLabel = 'Nhóm kích thước';
  static const String productBasicNoSizeGroup = 'Không có nhóm kích thước';
  static const String productBasicGenderLabel = 'Giới tính *';
  static const String productBasicGenderRequired = 'Vui lòng chọn giới tính';
  static const String productBasicGenderMale = 'Nam';
  static const String productBasicGenderFemale = 'Nữ';
  static const String productBasicGenderUnisex = 'Unisex';
  static const String productBasicStatusLabel = 'Trạng thái';
  static const String productBasicFeaturedTitle = 'Nổi bật';
  static const String productBasicFeaturedSubtitle = 'Hiển thị trên trang chủ';
  static const String productBasicNext = 'Tiếp theo';
  static const String productCategoryDepthPrefix = '—';

  // Admin review management
  static const String reviewsTitle = 'Quản lý đánh giá';
  static const String reviewsManagementLabel = 'Quản lý đánh giá';
  static const String reviewsEmptyTitle = 'Chưa có đánh giá nào';
  static const String reviewsEmptySubtitle =
      'Đánh giá của khách hàng sẽ hiển thị ở đây.';
  static const String reviewsLoadError = 'Không tải được đánh giá';
  static String reviewsCount(int count) => '$count đánh giá';
  static const String reviewReplyLabel = 'Phản hồi của shop';
  static const String reviewReplyAction = 'Trả lời';
  static const String reviewEditReplyAction = 'Sửa phản hồi';
  static const String reviewReplySheetTitle = 'Trả lời đánh giá';
  static const String reviewReplyHint = 'Nhập phản hồi cho khách hàng...';
  static const String reviewReplySubmit = 'Gửi phản hồi';
  static const String reviewReplySuccess = 'Đã gửi phản hồi';
  static const String reviewReplyRequired = 'Vui lòng nhập nội dung phản hồi';

  // Admin dashboard nav
  static const String dashboardLoadError =
      'Đã xảy ra lỗi khi tải dữ liệu Admin.';
  static const String navOverview = 'Tổng quan';
  static const String navManagement = 'Quản lý';
  static const String navOrders = 'Đơn hàng';
  static const String navStore = 'Cửa hàng';
  static const String navProfile = 'Cá nhân';

  // Admin order management
  static const String orderManagementTitle = 'Quản lý đơn hàng';
  static const String orderSearchHint = 'Tìm mã đơn, SĐT...';
  static const String orderDateRangeAll = 'Tất cả ngày';
  static const String orderDateRangeAction = 'Lọc ngày';
  static const String orderDateRangeClear = 'Xóa lọc ngày';
  static const String orderEmpty = 'Không có đơn hàng nào.';
  static const String orderDetailTitle = 'Chi tiết đơn hàng';
  static const String orderStatusUpdated = 'Đã cập nhật trạng thái đơn hàng!';
  static const String orderSelectStatus = 'Chọn trạng thái mới';
  static const String orderUpdating = 'Đang cập nhật...';
  static const String orderUpdateStatus = 'Cập nhật trạng thái';
  static String orderStatusChangeConfirm(String status) =>
      'Đổi trạng thái sang "$status"?';
  static const String filterAll = 'Tất cả';

  // Admin management tab
  static const String managementTitle = 'Quản lý';
  static const String managementSubtitle = 'Truy cập nhanh các mục quản trị';
  static const String manageProducts = 'Quản lý Sản phẩm';
  static const String manageBrands = 'Quản lý Thương hiệu';
  static const String manageColors = 'Quản lý Màu sắc';
  static const String manageCategories = 'Quản lý Danh mục';
  static const String manageCoupons = 'Quản lý Mã giảm giá';
  static const String manageSizes = 'Quản lý Kích thước';
  static const String supportMessages = 'Tin nhắn hỗ trợ';
  static const String returnPolicy = 'Chính sách đổi trả & bảo hành';

  // Admin dashboard tab
  static const String dashboardTitle = 'Dashboard';
  static const String dashboardStatisticsLabel = 'Thống kê';
  static const String revenueLabel = 'DOANH THU';
  static const String ordersCountLabel = 'ĐƠN HÀNG';
  static const String newCustomersLabel = 'KHÁCH MỚI';
  static const String trafficTitle = 'Lưu lượng truy cập';
  static const String trafficPeriod = 'TUẦN NÀY';
  static String trafficDay(String day, int value) =>
      'Lưu lượng $day: $value%';

  // Admin revenue analytics
  static const String revenueLoading = 'Đang tải…';
  static const String revenueEmptyRange =
      'Không có doanh thu trong khoảng đã chọn';
  static const String revenueErrorWithPrevious = 'Dữ liệu cũ đang được giữ lại';
  static const String revenueErrorNoData = 'Không thể tải dữ liệu doanh thu';
  static const String revenueRetry = 'Thử lại';
  static const String revenueGrowthNone = 'Không có dữ liệu kỳ trước';
  static const String revenueGrowthSuffix = 'so với kỳ trước';
  static const String revenuePreset7Days = '7 ngày';
  static const String revenuePreset30Days = '30 ngày';
  static const String revenuePresetThisMonth = 'Tháng này';
  static const String revenuePresetThisYear = 'Năm nay';
  static const String revenuePresetCustom = 'Tùy chọn';
  static const String revenuePresetThisWeek = 'Tuần này';
  static const String revenueFilter = 'Lọc';
  static const String revenueFilterTitle = 'Thời gian thống kê';
  static const String ordersSelectedPeriod = 'Trong khoảng đã chọn';
  static const String revenueInvalidRange = 'Khoảng ngày không hợp lệ';
  static String revenueRangeText(String start, String end) => '$start – $end';
  static String revenueDeliveredAndAverage(int count, String average) =>
      'Đơn đã giao: $count · Trung bình: $average';

  // Admin notification sheet
  static const String notificationSheetTitle = 'Thông báo đơn hàng mới';
  static const String notificationEmpty = 'Chưa có thông báo nào';
  static const String notificationDefaultTitle = 'Thông báo mới';
  static String notificationOrderText(dynamic orderId, String createdAt) =>
      'Đơn hàng #$orderId • $createdAt';

  // Admin order detail
  static const String orderInfoSection = 'THÔNG TIN ĐƠN HÀNG';
  static const String orderCodeLabel = 'Mã đơn hàng';
  static const String orderCustomerNameLabel = 'Tên người đặt';
  static const String orderPhoneLabel = 'Số điện thoại';
  static const String orderPaymentLabel = 'Thanh toán';
  static const String orderAddressSection = 'ĐỊA CHỈ GIAO HÀNG';
  static const String orderAddressLabel = 'Địa chỉ';
  static String orderItemsSection(int count) => 'SẢN PHẨM ($count)';
  static const String orderTotalLabel = 'Tổng cộng';

  // Admin location tab
  static const String locationTitle = 'Vị trí của cửa hàng';
  static const String showroomName = 'Sport Pro Showroom';
  static const String showroomLabel = 'SHOWROOM';
  static const String locationSearchHint = 'Tìm địa chỉ cửa hàng...';
  static const String locationSave = 'Lưu vị trí';
  static const String locationSaving = 'Đang lưu...';
  static const String locationSaveSuccess = 'Đã cập nhật vị trí cửa hàng';
  static const String locationNoSelection =
      'Tìm địa chỉ hoặc chạm bản đồ để chọn vị trí cửa hàng';

  // Admin profile tab
  static const String roleLabel = 'QUẢN TRỊ VIÊN';
  static const String shopViewLabel = 'Về Cửa hàng (User View)';
  static const String logoutLabel = 'Đăng xuất tài khoản';

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

  // Admin size group management
  static const String sizeGroupTitle = 'Nhóm kích thước';
  static const String sizeGroupCreateTitle = 'Tạo nhóm kích thước';
  static const String sizeGroupEditTitle = 'Sửa nhóm kích thước';
  static const String sizeGroupEmpty = 'Chưa có nhóm kích thước nào';
  static const String sizeGroupCreateAction = 'Tạo mới';
  static const String sizeGroupCreated = 'Đã tạo nhóm kích thước thành công!';
  static const String sizeGroupUpdated =
      'Đã cập nhật nhóm kích thước thành công!';
  static const String sizeGroupDeleted = 'Đã xóa nhóm kích thước thành công!';
  static const String sizeGroupDeleteTitle = 'Xác nhận xóa';
  static String sizeGroupDeleteBody(String name) =>
      'Bạn có chắc muốn xóa nhóm kích thước "$name"?';
  static const String sizeGroupNameLabel = 'Tên nhóm kích thước *';
  static const String sizeGroupNameRequired = 'Vui lòng nhập tên';
  static const String sizeGroupDescriptionLabel = 'Mô tả (tùy chọn)';
  static const String sizeGroupSave = 'Lưu';
  static const String sizeGroupSizeListLabel = 'Danh sách kích thước';
  static const String sizeGroupAddSize = 'Thêm kích thước';
  static const String sizeGroupSizeNameHint = 'Tên size (vd: M, 42)';
  static const String sizeGroupSizeOrderHint = 'Thứ tự';

  // Admin color management
  static const String colorManagementTitle = 'Quản lý Màu sắc';
  static const String colorProductTab = 'Màu sản phẩm';
  static const String colorPrintingTab = 'Màu in ấn';
  static const String colorStatusActive = 'Active';
  static const String colorStatusDisabled = 'Disabled';
  static const String colorPickerTitle = 'Chọn màu sắc';
  static const String colorPickerDone = 'XONG';
  static const String colorDeleteProductTitle = 'Xóa màu sản phẩm?';
  static String colorDeleteProductBody(String name) =>
      'Bạn có chắc muốn xóa màu "$name" khỏi sản phẩm?';
  static const String colorDeletePrintingTitle = 'Xóa màu in ấn?';
  static String colorDeletePrintingBody(String name) =>
      'Bạn có chắc muốn xóa màu in ấn "$name"?';
  static const String colorPrintingFormEditTitle = 'Sửa màu in ấn';
  static const String colorPrintingFormCreateTitle = 'Thêm màu in ấn mới';
  static const String colorPrintingNameLabel = 'TÊN MÀU IN';
  static const String colorPrintingNameHint =
      'Nhập tên màu in (ví dụ: Gold Foil)';
  static const String colorHexLabel = 'MÃ HEX (HEX CODE)';
  static const String colorPrintingHexHint = 'Nhập mã Hex (ví dụ: #D4AF37)';
  static const String colorPreviewLabel = 'Xem trước màu sắc';
  static const String colorPresetsLabel = 'MÀU ĐÃ CÓ SẴN (GỢI Ý)';
  static const String colorStatusLabel = 'TRẠNG THÁI HOẠT ĐỘNG';
  static const String colorPrintingNameRequired = 'Vui lòng nhập tên màu in!';
  static const String colorHexInvalid = 'Mã HEX không hợp lệ!';
  static const String colorSaveChanges = 'LƯU THAY ĐỔI';
  static const String colorCreatePrintingAction = 'THÊM MÀU IN ẤN';
  static const String colorProductFormEditTitle = 'Sửa màu sản phẩm';
  static const String colorProductFormCreateTitle = 'Thêm màu sản phẩm mới';
  static const String colorProductNameLabel = 'TÊN MÀU SẮC';
  static const String colorProductNameHint =
      'Nhập tên màu (ví dụ: Aero Blue)';
  static const String colorProductHexHint = 'Nhập mã Hex (ví dụ: #FF6D00)';
  static const String colorProductNameRequired = 'Vui lòng nhập tên màu!';
  static const String colorHexInvalidFull =
      'Mã HEX không hợp lệ! Vui lòng bắt đầu với # và có 3 hoặc 6 ký tự số/chữ.';
  static const String colorCreateProductAction = 'THÊM MÀU SẢN PHẨM';
  static const String colorProductEmpty = 'Chưa có màu sản phẩm nào.';
  static const String colorProductError = 'Lỗi tải màu sản phẩm.';
  static const String colorPrintingEmpty = 'Chưa có màu in ấn nào.';
  static const String colorPrintingError = 'Lỗi tải màu in ấn.';
  static const String colorPrintingCreated = 'Đã thêm màu in ấn thành công!';
  static const String colorPrintingUpdated =
      'Đã cập nhật màu in ấn thành công!';
  static const String colorPrintingDeleted = 'Đã xóa màu in ấn thành công!';
  static const String colorPrintingStatusUpdated =
      'Đã cập nhật trạng thái màu in!';
  static const String colorProductCreated = 'Đã thêm màu sản phẩm thành công!';
  static const String colorProductUpdated =
      'Đã cập nhật màu sản phẩm thành công!';
  static const String colorProductDeleted = 'Đã xóa màu sản phẩm thành công!';

  // Admin dashboard misc
  static const String dashboardAppName = 'Sport Pro';
  static String dashboardDate(String date) => date;
  static String dashboardChartTooltip(String day, int value) =>
      'Lưu lượng $day: $value%';

  // Admin profile
  static const String profileFallbackName = 'Admin Sport Pro';

  // Admin product form steps
  static const String productStepBasicInfo = 'Thông tin';
  static const String productStepVariants = 'Biến thể';
  static const String productStepImages = 'Hình ảnh';

  // Admin product form cubit
  static const String productLoadListError =
      'Không thể tải danh sách. Vui lòng thử lại.';
  static const String productFillRequired =
      'Vui lòng điền đầy đủ thông tin bắt buộc';
  static String productDeleteError(String msg) =>
      'Không thể xóa sản phẩm: $msg';

  // Admin bloc messages
  static const String blocUnknownError = 'Đã xảy ra lỗi không xác định.';
  static const String blocCreateSuccess = 'Đã thêm sản phẩm thành công!';
  static const String blocUpdateSuccess = 'Đã cập nhật sản phẩm thành công!';
  static const String blocDeleteSuccess = 'Đã xóa sản phẩm thành công!';
  static const String blocDeleteNotFound = 'Không tìm thấy sản phẩm để xóa.';

  // Admin order cubit
  static const String orderUpdateStatusSuccess =
      'Đã cập nhật trạng thái đơn hàng!';

  // Admin order entity
  static const String orderNoProduct = 'Không có sản phẩm';
}
