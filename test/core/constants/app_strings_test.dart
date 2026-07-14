import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

void main() {
  group('AppStrings', () {
    group('bottom navigation', () {
      test('navHome is non-empty', () {
        expect(AppStrings.navHome, isNotEmpty);
      });

      test('navShop is non-empty', () {
        expect(AppStrings.navShop, isNotEmpty);
      });

      test('navOrders is non-empty', () {
        expect(AppStrings.navOrders, isNotEmpty);
      });

      test('navProfile is non-empty', () {
        expect(AppStrings.navProfile, isNotEmpty);
      });
    });

    group('checkout strings', () {
      test('checkoutTitle is non-empty', () {
        expect(AppStrings.checkoutTitle, isNotEmpty);
      });

      test('checkoutShippingSectionTitle is non-empty', () {
        expect(AppStrings.checkoutShippingSectionTitle, isNotEmpty);
      });

      test('checkoutPaymentSectionTitle is non-empty', () {
        expect(AppStrings.checkoutPaymentSectionTitle, isNotEmpty);
      });

      test('checkoutCouponSectionTitle is non-empty', () {
        expect(AppStrings.checkoutCouponSectionTitle, isNotEmpty);
      });
    });

    group('parameterized methods', () {
      test('checkoutCouponApplied includes the coupon code', () {
        final result = AppStrings.checkoutCouponApplied('SAVE20');
        expect(result, contains('SAVE20'));
      });

      test('checkoutCouponSaved includes the amount', () {
        final result = AppStrings.checkoutCouponSaved('100,000');
        expect(result, contains('100,000'));
      });

      test('productFilterPriceBetween shows range format', () {
        final result = AppStrings.productFilterPriceBetween('50', '200');
        expect(result, contains('50'));
        expect(result, contains('200'));
      });

      test('productFilterPriceFrom includes the price', () {
        final result = AppStrings.productFilterPriceFrom('1000');
        expect(result, contains('1000'));
      });

      test('productFilterPriceTo includes the price', () {
        final result = AppStrings.productFilterPriceTo('5000');
        expect(result, contains('5000'));
      });

      test('cartSelectAll includes counts', () {
        final result = AppStrings.cartSelectAll(3, 10);
        expect(result, contains('3'));
        expect(result, contains('10'));
      });

      test('orderProductsSectionTitle includes count', () {
        final result = AppStrings.orderProductsSectionTitle(5);
        expect(result, contains('5'));
      });
    });

    group('cart strings', () {
      test('cartTitle is non-empty', () {
        expect(AppStrings.cartTitle, isNotEmpty);
      });

      test('cartEmptyTitle is non-empty', () {
        expect(AppStrings.cartEmptyTitle, isNotEmpty);
      });

      test('cartRemoveItemTitle is non-empty', () {
        expect(AppStrings.cartRemoveItemTitle, isNotEmpty);
      });
    });

    group('order strings', () {
      test('orderListTitle is non-empty', () {
        expect(AppStrings.orderListTitle, isNotEmpty);
      });

      test('orderListSectionLabel is non-empty', () {
        expect(AppStrings.orderListSectionLabel, isNotEmpty);
      });

      test('orderDetailLoadError is non-empty', () {
        expect(AppStrings.orderDetailLoadError, isNotEmpty);
      });
    });

    group('login strings', () {
      test('loginTitle is non-empty', () {
        expect(AppStrings.loginTitle, isNotEmpty);
      });

      test('loginSubmit is non-empty', () {
        expect(AppStrings.loginSubmit, isNotEmpty);
      });
    });

    group('product strings', () {
      test('productFilterTitle is non-empty', () {
        expect(AppStrings.productFilterTitle, isNotEmpty);
      });

      test('productFilterCategory is non-empty', () {
        expect(AppStrings.productFilterCategory, isNotEmpty);
      });

      test('designViewerInvalidId is non-empty', () {
        expect(AppStrings.designViewerInvalidId, isNotEmpty);
      });
    });
  });
}
