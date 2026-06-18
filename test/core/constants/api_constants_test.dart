import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';

void main() {
  group('ApiConstants dynamic methods', () {
    test('vnpayVerify builds correct path', () {
      expect(ApiConstants.vnpayVerify(99), '/api/v1/payments/vnpay/verify/99');
    });

    test('customDesignById builds correct path', () {
      expect(ApiConstants.customDesignById(5), '/api/custom-designs/5');
    });

    test('addressById builds correct path', () {
      expect(ApiConstants.addressById(3), '/api/v1/addresses/3');
    });

    test('addressSetDefault builds correct path', () {
      expect(
        ApiConstants.addressSetDefault(7),
        '/api/v1/addresses/7/default',
      );
    });

    test('adminProductById builds correct path', () {
      expect(ApiConstants.adminProductById(10), '/api/admin/products/10');
    });

    test('adminProductVariants builds correct path', () {
      expect(
        ApiConstants.adminProductVariants(2),
        '/api/admin/products/2/variants',
      );
    });

    test('adminProductImages builds correct path', () {
      expect(
        ApiConstants.adminProductImages(4),
        '/api/admin/products/4/images',
      );
    });

    test('adminVariantById builds correct path', () {
      expect(
        ApiConstants.adminVariantById(8),
        '/api/admin/product-variants/8',
      );
    });

    test('adminImageById builds correct path', () {
      expect(ApiConstants.adminImageById(15), '/api/admin/product-images/15');
    });
  });

  group('ApiConstants static paths', () {
    test('login path is correct', () {
      expect(ApiConstants.login, '/api/auth/login');
    });

    test('addresses path is correct', () {
      expect(ApiConstants.addresses, '/api/v1/addresses');
    });

    test('orders path is correct', () {
      expect(ApiConstants.orders, '/api/v1/orders');
    });
  });
}
