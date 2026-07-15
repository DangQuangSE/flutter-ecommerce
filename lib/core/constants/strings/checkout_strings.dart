/// Checkout and payment feature strings.
abstract final class CheckoutStrings {
  // Checkout shipping form
  static const String title = 'THANH TOÁN';
  static const String shippingSectionTitle = 'THÔNG TIN GIAO HÀNG';
  static const String paymentSectionTitle = 'PHƯƠNG THỨC THANH TOÁN';
  static const String couponSectionTitle = 'MÃ GIẢM GIÁ (COUPON)';
  static const String addressRequired = 'Vui lòng chọn địa chỉ giao hàng!';
  static const String shippingInfoRequired =
      'Vui lòng điền đầy đủ thông tin giao hàng!';
  static const String fullNameLabel = 'HỌ VÀ TÊN';
  static const String fullNameRequired = 'Vui lòng nhập họ và tên';
  static const String phoneLabel = 'SỐ ĐIỆN THOẠI';
  static const String phoneRequired = 'Vui lòng nhập số điện thoại';
  static const String phoneInvalid =
      'Số điện thoại không hợp lệ (VD: 0912345678)';
  static const String shippingAddressLabel = 'ĐỊA CHỈ GIAO HÀNG';
  static const String shippingAddressRequired =
      'Vui lòng nhập địa chỉ giao hàng';
  static const String shippingEditHint =
      'Bạn có thể chỉnh sửa thông tin giao hàng bên dưới nếu cần.';

  // Commerce common
  static const String emptyTitle = 'ĐƠN HÀNG RỖNG';
  static const String emptyMessage =
      'Không tìm thấy sản phẩm nào để thanh toán. Hãy quay về giỏ hàng hoặc tiếp tục mua sắm nhé!';
  static const String backToShopping = 'QUAY LẠI MUA SẮM';
  static const String loadErrorTitle = 'Không thể tải thông tin thanh toán.';
  static const String retry = 'Thử lại';
  static const String subtotalLabel = 'Tạm tính';
  static const String productCountSuffix = 'sản phẩm';
  static const String voucherDiscountLabel = 'Giảm giá (Voucher)';
  static const String expressShippingLabel = 'Giao hàng hỏa tốc';
  static const String freeShipping = 'Miễn phí';
  static const String grandTotalLabel = 'TỔNG CỘNG';
  static const String couponPickerTitle = 'Chọn Sport Pro Voucher';
  static const String couponInvalid =
      'Mã giảm giá không hợp lệ hoặc đã hết hạn';
  static const String couponMinOrderNotMet =
      'Đơn hàng chưa đạt giá trị tối thiểu';
  static const String couponAvailableSection = 'MÃ GIẢM GIÁ KHẢ DỤNG';
  static const String couponUnavailableSection = 'MÃ KHÔNG KHẢ DỤNG';
  static const String couponEmpty = 'Không có mã giảm giá nào';
  static const String noAddressTitle = 'CHƯA CÓ ĐỊA CHỈ GIAO HÀNG';
  static const String noAddressMessage =
      'Thêm địa chỉ giao hàng để tiến hành đặt hàng.';
  static const String addAddress = 'THÊM ĐỊA CHỈ';
  static const String addNewAddress = 'THÊM ĐỊA CHỈ MỚI';
  static const String defaultAddress = 'MẶC ĐỊNH';
  static const String changeAddress = 'THAY ĐỔI';
  static const String selectAddressTitle = 'CHỌN ĐỊA CHỈ GIAO HÀNG';
  static const String voucherTitle = 'Sport Pro Voucher';
  static String couponApplied(String code) => 'Đã áp dụng mã: $code';
  static String couponSaved(String amount) => 'Tiết kiệm được $amount';
  static const String couponLoadError =
      'Không tải được mã giảm giá. Nhấn để thử lại.';
  static const String couponLoading = 'Đang tải mã giảm giá...';
  static const String couponChooseOrEnter = 'Chọn hoặc nhập mã giảm giá';

  // Payment
  static const String ok = 'OK';
  static const String vnpayTitle = 'VNPay';
  static const String cancelTitle = 'Hủy thanh toán?';
  static const String cancelMessage =
      'Bạn có chắc muốn hủy thanh toán VNPay? Đơn hàng vẫn ở trạng thái chờ thanh toán.';
  static const String continuePayment = 'Tiếp tục';
  static const String cancel = 'Hủy';
  static const String successTitle = 'Thanh toán thành công';
  static const String failureTitle = 'Thanh toán thất bại';
  static const String backHome = 'VỀ TRANG CHỦ';
}
