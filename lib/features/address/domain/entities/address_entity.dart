import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final String addressLine;
  final String ward;
  final String district;
  final String city;
  final String? label;
  final bool isDefault;

  const AddressEntity({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine,
    required this.ward,
    required this.district,
    required this.city,
    this.label,
    this.isDefault = false,
  });

  AddressEntity copyWith({
    int? id,
    String? fullName,
    String? phoneNumber,
    String? addressLine,
    String? ward,
    String? district,
    String? city,
    String? label,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine: addressLine ?? this.addressLine,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get formattedAddress =>
      '$addressLine, $ward, $district, $city';

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        addressLine,
        ward,
        district,
        city,
        label,
        isDefault,
      ];
}
