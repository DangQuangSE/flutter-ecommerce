/// Cart feature strings.
abstract final class CartStrings {
  // Empty / error states
  static const String emptyTitle = 'GIỎ HÀNG TRỐNG';
  static const String emptyMessage =
      'Bạn chưa thêm bất kỳ sản phẩm nào vào giỏ hàng. Hãy khám phá bộ sưu tập thể thao Pro ngay!';
  static const String loadErrorTitle = 'Không thể tải thông tin giỏ hàng.';
  static const String continueShopping = 'TIẾP TỤC MUA SẮM';

  // Cart page
  static const String title = 'GIỎ HÀNG';
  static const String listTitle = 'DANH SÁCH GIỎ HÀNG';
  static String selectAll(int selected, int total) =>
      'CHỌN TẤT CẢ ($selected/$total)';
  static const String removeItemTitle = 'Xóa sản phẩm?';
  static String removeItemMessage(String name) =>
      'Bạn có chắc chắn muốn xóa $name khỏi giỏ hàng?';
  static const String removeItemConfirm = 'XÓA BỎ';
  static const String removeDesignTitle = 'Xóa thiết kế in ấn?';
  static String removeDesignMessage(String name) =>
      'Bạn có chắc muốn xóa thiết kế in ấn khỏi sản phẩm $name? Thiết kế của bạn sẽ bị hủy và sản phẩm được trả về dạng nguyên bản.';
  static const String removeDesignConfirm = 'XÓA THIẾT KẾ';

  // Custom design spec display (used inside cart items)
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
      'Công thức: (Số lớp chữ x $textUnitPrice/lớp) + (Số logo x $imageUnitPrice/ảnh)';
}
