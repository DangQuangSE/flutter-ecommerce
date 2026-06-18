class LocationModel {
  final int code;
  final String name;

  const LocationModel({required this.code, required this.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        code: json['code'] as int,
        name: json['name'] as String,
      );

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocationModel && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
