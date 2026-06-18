import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.addressLine,
    required super.ward,
    required super.district,
    required super.city,
    super.label,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as int?,
        fullName: json['fullName'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        addressLine: json['addressLine'] as String? ?? '',
        ward: json['ward'] as String? ?? '',
        district: json['district'] as String? ?? '',
        city: json['city'] as String? ?? '',
        label: json['label'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
      );

  factory AddressModel.fromEntity(AddressEntity entity) => AddressModel(
        id: entity.id,
        fullName: entity.fullName,
        phoneNumber: entity.phoneNumber,
        addressLine: entity.addressLine,
        ward: entity.ward,
        district: entity.district,
        city: entity.city,
        label: entity.label,
        isDefault: entity.isDefault,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'addressLine': addressLine,
        'ward': ward,
        'district': district,
        'city': city,
        if (label != null) 'label': label,
        'isDefault': isDefault,
      };
}
