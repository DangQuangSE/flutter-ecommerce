class LocationEntity {
  final int code;
  final String name;

  const LocationEntity({required this.code, required this.name});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocationEntity && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
