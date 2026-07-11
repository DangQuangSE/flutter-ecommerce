import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/order/data/models/order_item_model.dart';

void main() {
  test('parses custom printing tracking fields from order API', () {
    final item = OrderItemModel.fromJson({
      'id': 2,
      'productName': 'Polo',
      'size': 'S',
      'color': 'Black',
      'quantity': 2,
      'price': 199000,
      'customDesignId': '17',
      'designImageUrl': 'https://example.test/design.png',
      'printingPrice': 25000,
    });

    expect(item.hasCustomPrinting, isTrue);
    expect(item.customDesignId, 17);
    expect(item.designImageUrl, contains('design.png'));
    expect(item.printingLineTotal, 50000);
  });
}
