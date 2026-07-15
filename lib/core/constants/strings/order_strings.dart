/// Order list and detail feature strings (customer-facing).
abstract final class OrderStrings {
  static const String listSectionLabel = 'QUẢN LÝ GIAO DỊCH';
  static const String listTitle = 'Đơn Hàng Của Tôi';
  static const String filterAll = 'Tất cả';
  static const String emptyTitle = 'Không có đơn hàng nào';
  static const String emptySubtitle =
      'Các giao dịch thuộc danh mục này sẽ xuất hiện tại đây.';
  static const String listLoadError =
      'Không thể tải đơn hàng. Vui lòng thử lại sau.';
  static const String quantityLabel = 'Số lượng';
  static const String detailLoadError =
      'Không thể tải chi tiết đơn hàng. Vui lòng thử lại sau.';
  static const String infoSectionTitle = 'THÔNG TIN ĐƠN HÀNG';
  static const String codeLabel = 'Mã đơn hàng';
  static const String dateLabel = 'Ngày đặt';
  static const String paymentMethodLabel = 'Phương thức thanh toán';
  static const String shippingAddressSectionTitle = 'ĐỊA CHỈ GIAO HÀNG';
  static const String shippingAddressLabel = 'Địa chỉ';
  static String productsSectionTitle(int count) => 'SẢN PHẨM ($count)';
  static const String sizeLabel = 'Size';
  static const String totalLabel = 'TỔNG THANH TOÁN';
  static const String continueShopping = 'TIẾP TỤC MUA SẮM';
  static const String trackOrder = 'THEO DÕI ĐƠN';
  static const String subtotal = 'Tạm tính';
  static String customPrinting(int designId, String price) =>
      'In tùy chỉnh #$designId · +$price';
  static const String writeReviewAction = 'Đánh giá';
  static const String reviewedLabel = 'Đã đánh giá';

  // Design viewer
  static const String designViewerTitle = 'Chi tiết bản thiết kế';
  static const String designViewerFront = 'Mặt trước';
  static const String designViewerBack = 'Mặt sau';
  static const String designViewerLayers = 'Thành phần thiết kế';
  static const String designViewerNoLayers = 'Không có thành phần ở mặt này';
  static const String designViewerLimited =
      'Metadata không đầy đủ; ảnh preview vẫn là bản thiết kế chính xác.';
  static const String designViewerOpenPreview = 'Mở preview';
  static const String designViewerOpenFailed = 'Không thể mở ảnh preview';
  static const String designViewerViewAction = 'Xem thiết kế';
  static const String designViewerMaterial = 'Chất liệu';
  static const String designViewerPrintingPrice = 'Phí in';
  static const String designViewerInvalidId = 'Mã thiết kế không hợp lệ';
  static const String designViewerAssetAvailable = 'Có file logo';
  static const String designViewerAssetUnavailable = 'Không có file logo gốc';
}
