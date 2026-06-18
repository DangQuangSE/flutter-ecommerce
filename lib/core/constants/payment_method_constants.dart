enum CheckoutPaymentOption {
  cod,
  vnpay;

  String get apiValue => switch (this) {
        CheckoutPaymentOption.cod => 'COD',
        CheckoutPaymentOption.vnpay => 'BANK_TRANSFER',
      };

  String get label => switch (this) {
        CheckoutPaymentOption.cod => 'Thanh toán khi nhận hàng (COD)',
        CheckoutPaymentOption.vnpay => 'VNPay',
      };

  String get subtitle => switch (this) {
        CheckoutPaymentOption.cod => 'Trả tiền mặt khi nhận hàng',
        CheckoutPaymentOption.vnpay => 'Thanh toán online qua VNPay',
      };
}
