/// Admin feature strings
abstract final class AdminStrings {
  // Admin product - bulk variants
  static const String productBulkTitle = 'Tạo nhanh biến thể';
  static const String productBulkSizeGroupStep = '1. CHỌN NHÓM SIZE';
  static const String productBulkSizeGroupHint = 'Chọn nhóm kích thước';
  static const String productBulkSizeGroupRequired = 'Vui lòng chọn nhóm size';
  static const String productBulkSizeStep = '2. TÙY CHỌN KÍCH THƯỚC';
  static const String productBulkColorStep = '3. CHỌN MÀU SẮC';
  static const String productBulkDefaultsStep = '4. THÔNG SỐ BIẾN THỂ MẶC ĐỊNH';
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
  static const String productVariantEmptyHint = 'Nhấn "Thêm biến thể" để thêm mới';
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
  static String productDetailLabel(String label, String value) => '$label: $value';
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
  static const String categorySearchHint = 'Tìm danh mục...';
  static const String categoryManagementTitle = 'Quản lý danh mục';
  static const String categoryViewTree = 'Xem cây danh mục';
  static const String categoryEmptyTitle = 'Chưa có danh mục nào';
  static const String categoryEmptyMessage = 'Nhấn "Thêm" để tạo danh mục đầu tiên.';
  static const String categoryLoadErrorTitle = 'Không tải được danh mục';
  static const String categoryDeleted = 'Đã xóa danh mục';
  static const String categoryCreated = 'Đã tạo danh mục';
  static const String categoryUpdated = 'Đã cập nhật danh mục';
  static const String categoryDeleteTitle = 'Xóa danh mục';
  static String categoryDeleteMessage(String name) => 'Bạn có chắc muốn xóa "$name"?';
  static const String categoryTreeTitle = 'Cây danh mục';
  static const String categoryTreeEmpty = 'Không có dữ liệu.';
  static String categoryCount(int count) => '$count danh mục';
  static const String couponSearchHint = 'Tìm theo mã giảm giá...';
  static const String couponEmptyTitle = 'Chưa có mã giảm giá nào';
  static const String couponEmptyMessage = 'Nhấn "Thêm" để tạo mã đầu tiên.';
  static const String couponAdd = 'Thêm mã';
  static const String couponLoadErrorTitle = 'Không tải được mã giảm giá';
  static const String couponDeleteTitle = 'Xóa mã giảm giá';
  static const String couponDeleted = 'Đã xóa mã giảm giá';
  static String couponDeleteMessage(String code) => 'Bạn có chắc muốn xóa mã "$code"?';
  static const String couponCreated = 'Đã tạo mã giảm giá';
  static const String couponUpdated = 'Đã cập nhật mã giảm giá';
  static const String couponEndDateAfterStart = 'Ngày kết thúc phải sau ngày bắt đầu';
  static const String couponCreateSubmit = 'Tạo mã giảm giá';
  static const String couponSaveSubmit = 'Lưu thay đổi';
  static String couponTotalCount(int count) => '$count mã giảm giá';
  static String couponFilteredCount(int filtered, int total) => '$filtered/$total mã';
  static String couponNoMatches(String query) => 'Không có mã nào khớp "$query".';
  static String couponUsedWithLimit(int used, int limit) => 'Đã dùng $used/$limit';
  static String couponUsed(int used) => 'Đã dùng $used';
  static String couponExpires(String date) => 'HSD $date';
  static const String couponExpired = 'Hết hạn';
  static const String couponUsedUp = 'Hết lượt';
}
