/// Customizer feature strings.
abstract final class CustomizerStrings {
  static const String defaultPrintMethod = 'In chuyển nhiệt';
  static const String defaultTextLayer = 'LỚP CHỮ MỚI';
  static const String defaultLayerText = 'SPORT PRO';
  static const String defaultTeamText = 'TEAM SPORT';
  static const String defaultTextColor = 'Jet Black';
  static const String uploadImageError =
      'Không thể tải ảnh. Vui lòng kiểm tra quyền truy cập thư viện.';
  static const String uploadLogoServerError =
      'Không thể tải logo lên. Vui lòng thử lại.';
  static const String colorPickerTitle = 'Chọn màu sắc in';
  static const String captureError = 'Không thể chụp hình thiết kế.';
  static const String saveSuccess =
      'Đã lưu thiết kế lên hệ thống thành công!';
  static const String syncError = 'Không thể đồng bộ với server.';
  static const String loading = 'Đang tải cấu hình in ấn...';
  static const String loadError = 'Không thể tải cấu hình in ấn.';
  static const String saving = 'Đang lưu thiết kế lên server...';
  static const String title = 'TÙY CHỈNH THIẾT KẾ';
  static const String panelSubtitle =
      'Tự tay thiết kế áo thi đấu đẳng cấp cao. Tên, số áo và logo tùy chỉnh theo ý bạn.';
  static const String materialSection = 'CHẤT LIỆU IN ẤN';
  static const String textEditorTitle = 'CHỈNH SỬA CHỮ / SỐ';
  static const String addLayer = 'THÊM LỚP MỚI';
  static const String textLayerContent = 'NỘI DUNG LỚP CHỮ';
  static const String font = 'FONT CHỮ';
  static const String sportFontSuffix = 'Thể thao';
  static const String printColor = 'MÀU SẮC IN';
  static const String fontSize = 'CỠ CHỮ';
  static const String noTextLayerSelected =
      'Chọn hoặc thêm một lớp chữ để bắt đầu chỉnh sửa.';
  static const String uploadLogoTitle = 'TẢI LÊN LOGO CỦA BẠN';
  static const String uploadLogoAction = 'NHẤN ĐỂ TẢI ẢNH LÊN';
  static const String uploadLogoInProgress = 'ĐANG TẢI LÊN...';
  static const String uploadLogoHint = 'PNG, JPG, WEBP (Tối đa 5MB)';
  static const String totalProduct = 'TỔNG CỘNG SẢN PHẨM';
  static const String printingPriceLabel = 'Giá in thêm';
  static const String printingPriceHint = '(Theo số lớp & logo)';
  static const String selectedColor = 'Selected Color';
  static String sportFontLabel(String font) =>
      '$font ($sportFontSuffix)';
  static String printingPrice(String price) =>
      '$printingPriceLabel: $price ₫';
}
