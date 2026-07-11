import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/custom_design_spec_entity.dart';

double backendCartSubtotal(Iterable<CartItemEntity> items) =>
    items.fold(0.0, (sum, item) => sum + item.itemTotal);

double resolvedDisplayPrintingPrice(
  CartItemEntity item, {
  CustomDesignSpecEntity? spec,
}) {
  if (item.customDesignId == null) return item.printingPrice;
  return resolvedPrintingPriceFromSpec(
    spec: spec,
    fallbackPrintingPrice: item.printingPrice,
  );
}

double resolvedPrintingPriceFromSpec({
  required CustomDesignSpecEntity? spec,
  required double fallbackPrintingPrice,
}) {
  if (spec == null) return fallbackPrintingPrice;

  final textCost = spec.numTextLines * spec.textUnitPrice;
  final imageCost = spec.numImages * spec.imageUnitPrice;
  final computed = textCost + imageCost;
  if (computed > 0) return computed;
  if (spec.totalPrintingPrice > 0) return spec.totalPrintingPrice;
  return fallbackPrintingPrice;
}
