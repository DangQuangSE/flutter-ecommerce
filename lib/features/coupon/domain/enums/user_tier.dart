/// Mirrors the backend `UserTier` enum (auth module).
///
/// A coupon may require a minimum membership tier, or none (`null`) so any
/// customer can use it.
enum UserTier {
  bronze('BRONZE', 'Đồng'),
  silver('SILVER', 'Bạc'),
  gold('GOLD', 'Vàng'),
  platinum('PLATINUM', 'Bạch kim');

  final String wireName;
  final String label;

  const UserTier(this.wireName, this.label);

  /// Parses an API value; returns `null` when absent or unrecognised.
  static UserTier? fromWire(String? value) {
    if (value == null) return null;
    for (final tier in UserTier.values) {
      if (tier.wireName == value) return tier;
    }
    return null;
  }
}
