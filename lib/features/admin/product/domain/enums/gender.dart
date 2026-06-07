enum Gender {
  male,
  female,
  unisex;

  String toJson() => name.toUpperCase();

  static Gender fromJson(String v) => Gender.values.firstWhere(
        (e) => e.name == v.toLowerCase(),
        orElse: () => Gender.unisex,
      );
}
