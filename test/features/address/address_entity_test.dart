import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

AddressEntity _makeAddress({
  int? id = 1,
  String fullName = 'Nguyen Van A',
  String phoneNumber = '0987654321',
  String addressLine = '123 Le Loi',
  String ward = 'Phuong Ben Nghe',
  String district = 'Quan 1',
  String city = 'TP. Ho Chi Minh',
  String? label,
  bool isDefault = false,
}) =>
    AddressEntity(
      id: id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      addressLine: addressLine,
      ward: ward,
      district: district,
      city: city,
      label: label,
      isDefault: isDefault,
    );

void main() {
  group('AddressEntity.fullAddress', () {
    test('concatenates addressLine, ward, district, city', () {
      final address = _makeAddress();
      expect(
        address.fullAddress,
        '123 Le Loi, Phuong Ben Nghe, Quan 1, TP. Ho Chi Minh',
      );
    });
  });

  group('AddressEntity.copyWith', () {
    test('returns new instance with updated fullName', () {
      final original = _makeAddress();
      final updated = original.copyWith(fullName: 'Tran Thi B');
      expect(updated.fullName, 'Tran Thi B');
      expect(updated.phoneNumber, original.phoneNumber);
    });

    test('returns new instance with updated isDefault', () {
      final original = _makeAddress(isDefault: false);
      final updated = original.copyWith(isDefault: true);
      expect(updated.isDefault, isTrue);
      expect(original.isDefault, isFalse);
    });

    test('preserves null id when not overridden', () {
      final address = _makeAddress(id: null);
      final updated = address.copyWith(fullName: 'New Name');
      expect(updated.id, isNull);
    });

    test('updates label from null to value', () {
      final original = _makeAddress(label: null);
      final updated = original.copyWith(label: 'Home');
      expect(updated.label, 'Home');
    });
  });

  group('AddressEntity Equatable', () {
    test('two identical addresses are equal', () {
      final a = _makeAddress();
      final b = _makeAddress();
      expect(a, equals(b));
    });

    test('addresses with different phoneNumber are not equal', () {
      final a = _makeAddress(phoneNumber: '0111111111');
      final b = _makeAddress(phoneNumber: '0999999999');
      expect(a, isNot(equals(b)));
    });

    test('addresses with and without label are not equal', () {
      final a = _makeAddress(label: 'Home');
      final b = _makeAddress(label: null);
      expect(a, isNot(equals(b)));
    });
  });
}
