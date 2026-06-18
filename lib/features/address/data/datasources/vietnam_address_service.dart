import 'package:dio/dio.dart';

class VietnamProvince {
  final int code;
  final String name;
  final String codename;
  final String divisionType;

  const VietnamProvince({
    required this.code,
    required this.name,
    required this.codename,
    required this.divisionType,
  });

  factory VietnamProvince.fromJson(Map<String, dynamic> json) {
    return VietnamProvince(
      code: json['code'] as int,
      name: json['name'] as String? ?? '',
      codename: json['codename'] as String? ?? '',
      divisionType: json['division_type'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietnamProvince &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class VietnamDistrict {
  final int code;
  final String name;
  final String codename;
  final String divisionType;
  final int provinceCode;

  const VietnamDistrict({
    required this.code,
    required this.name,
    required this.codename,
    required this.divisionType,
    required this.provinceCode,
  });

  factory VietnamDistrict.fromJson(Map<String, dynamic> json) {
    return VietnamDistrict(
      code: json['code'] as int,
      name: json['name'] as String? ?? '',
      codename: json['codename'] as String? ?? '',
      divisionType: json['division_type'] as String? ?? '',
      provinceCode: json['province_code'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietnamDistrict &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class VietnamWard {
  final int code;
  final String name;
  final String codename;
  final String divisionType;
  final int districtCode;

  const VietnamWard({
    required this.code,
    required this.name,
    required this.codename,
    required this.divisionType,
    required this.districtCode,
  });

  factory VietnamWard.fromJson(Map<String, dynamic> json) {
    return VietnamWard(
      code: json['code'] as int,
      name: json['name'] as String? ?? '',
      codename: json['codename'] as String? ?? '',
      divisionType: json['division_type'] as String? ?? '',
      districtCode: json['district_code'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietnamWard &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class VietnamAddressService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<VietnamProvince>> getProvinces() async {
    final response = await _dio.get<List<dynamic>>('https://provinces.open-api.vn/api/p/');
    if (response.data == null) return [];
    return response.data!
        .map((json) => VietnamProvince.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<VietnamDistrict>> getDistricts(int provinceCode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://provinces.open-api.vn/api/p/$provinceCode',
      queryParameters: {'depth': 2},
    );
    final districtsList = response.data?['districts'] as List<dynamic>?;
    if (districtsList == null) return [];
    return districtsList
        .map((json) => VietnamDistrict.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<VietnamWard>> getWards(int districtCode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://provinces.open-api.vn/api/d/$districtCode',
      queryParameters: {'depth': 2},
    );
    final wardsList = response.data?['wards'] as List<dynamic>?;
    if (wardsList == null) return [];
    return wardsList
        .map((json) => VietnamWard.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
