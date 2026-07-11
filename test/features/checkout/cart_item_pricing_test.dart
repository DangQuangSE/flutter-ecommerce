import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/utils/cart_item_pricing.dart';

void main() {
  test('checkout subtotal trusts backend itemTotal for custom items', () {
    const item = CartItemEntity(
      itemId: 2,
      variantId: 10,
      productName: 'Polo',
      productSlug: 'polo',
      originalPrice: 199000,
      salePrice: 199000,
      quantity: 1,
      itemTotal: 269000,
      customDesignId: 7,
      printingPrice: 50000,
    );

    expect(backendCartSubtotal(const [item]), 269000);
  });
}
