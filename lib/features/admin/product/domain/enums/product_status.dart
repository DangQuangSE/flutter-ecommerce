enum ProductStatus {
  active,
  inactive,
  deleted;

  String toJson() => name.toUpperCase();

  static ProductStatus fromJson(String v) => ProductStatus.values.firstWhere(
        (e) => e.name == v.toLowerCase(),
        orElse: () => ProductStatus.active,
      );
}
