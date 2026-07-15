/// Shop info and config feature strings.
abstract final class ShopStrings {
  // Shop info (user-facing)
  static const String infoTitle = 'Thông tin cửa hàng';
  static const String descriptionLabel = 'MÔ TẢ';
  static String ratingCount(int count) => '($count đánh giá)';
  static const String loadError =
      'Không thể tải thông tin cửa hàng. Vui lòng thử lại sau.';

  // Shop map & directions (user-facing)
  static const String getDirections = 'Chỉ đường';
  static const String directionsLoading = 'Đang tìm đường...';
  static const String mapOpenError = 'Không thể mở Google Maps.';
  static const String mapUnavailable =
      'Chưa có vị trí bản đồ cho cửa hàng này.';

  // Admin shop config
  static const String adminConfigTitle = 'Cấu hình cửa hàng';
  static const String saveChanges = 'Lưu thay đổi';
  static const String updateSuccess =
      'Đã cập nhật thông tin cửa hàng thành công!';
  static const String updateError =
      'Cập nhật cửa hàng thất bại. Vui lòng thử lại.';
  static const String imageUploadError =
      'Tải ảnh lên thất bại. Vui lòng thử lại.';
  static const String coverPickerLabel = 'Ảnh bìa cửa hàng';
  static const String logoPickerLabel = 'Logo cửa hàng';

  // Shop form field labels
  static const String fieldName = 'Tên cửa hàng *';
  static const String fieldNameHint = 'Nhập tên cửa hàng';
  static const String fieldAddress = 'Địa chỉ';
  static const String fieldAddressHint = 'Nhập địa chỉ cửa hàng';
  static const String fieldRating = 'Đánh giá (0.0 – 5.0)';
  static const String fieldRatingHint = 'Ví dụ: 4.8';
  static const String fieldRatingCount = 'Số lượt đánh giá';
  static const String fieldRatingCountHint = 'Ví dụ: 1200';
  static const String fieldPhone = 'Số điện thoại';
  static const String fieldPhoneHint = 'Nhập số điện thoại liên hệ';
  static const String fieldOpeningHours = 'Giờ mở cửa';
  static const String fieldOpeningHoursHint =
      'Ví dụ: 8:00 – 21:00 (T2 – CN)';
  static const String fieldDescription = 'Mô tả cửa hàng';
  static const String fieldDescriptionHint =
      'Nhập mô tả ngắn về cửa hàng...';
  static const String fieldLogoUrl = 'URL Logo';
  static const String fieldLogoUrlHint = 'Nhập đường dẫn ảnh logo cửa hàng';
  static const String fieldCoverUrl = 'URL Ảnh bìa';
  static const String fieldCoverUrlHint = 'Nhập đường dẫn ảnh bìa cửa hàng';

  // Shop form validation
  static const String validationNameRequired =
      'Tên cửa hàng không được để trống';
  static const String validationRatingInvalid =
      'Đánh giá phải là số thực (ví dụ: 4.8)';
  static const String validationRatingRange =
      'Đánh giá phải nằm trong khoảng 0.0 – 5.0';
  static const String validationRatingCountInvalid =
      'Số lượt đánh giá phải là số nguyên không âm';

  // Menu labels
  static const String infoMenuLabel = 'Thông tin cửa hàng';
  static const String adminConfigMenuLabel = 'Cấu hình cửa hàng';
}
