/// Mirrors the backend `DiscountType` enum (coupon module).
///
/// [wireName] is the exact string the API sends/expects; [label] is the
/// Vietnamese text shown in the admin UI.
enum DiscountType {
  percentage('PERCENTAGE', 'Phần trăm (%)'),
  fixedAmount('FIXED_AMOUNT', 'Số tiền cố định (đ)');

  final String wireName;
  final String label;

  const DiscountType(this.wireName, this.label);

  /// Parses an API value, defaulting to [percentage] for unknown/null input.
  static DiscountType fromWire(String? value) {
    for (final type in DiscountType.values) {
      if (type.wireName == value) return type;
    }
    return DiscountType.percentage;
  }
}
