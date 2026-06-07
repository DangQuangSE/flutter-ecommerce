import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_page.dart';

abstract interface class CouponRemoteDataSource {
  Future<CouponPage> getCoupons({int page, int size});
  Future<CouponModel> create(CouponModel coupon);
  Future<CouponModel> update(int id, CouponModel coupon);
  Future<void> delete(int id);
}

/// Talks to the admin coupon API (`/api/v1/admin/coupons`) over the shared
/// [DioClient], which attaches the logged-in admin's Bearer token. All
/// endpoints require the `ADMIN` role on the backend.
class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final DioClient _dioClient;

  const CouponRemoteDataSourceImpl(this._dioClient);

  @override
  Future<CouponPage> getCoupons({int page = 0, int size = 100}) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.adminCoupons,
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Phản hồi danh sách mã giảm giá không hợp lệ');
    }
    final content = (data['content'] as List<dynamic>? ?? [])
        .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CouponPage(
      items: content,
      page: (data['number'] as num?)?.toInt() ?? page,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      totalElements: (data['totalElements'] as num?)?.toInt() ?? content.length,
      isLast: data['last'] as bool? ?? true,
    );
  }

  @override
  Future<CouponModel> create(CouponModel coupon) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.adminCoupons,
      data: coupon.toRequestJson(),
    );
    return _parseSingle(response.data);
  }

  @override
  Future<CouponModel> update(int id, CouponModel coupon) async {
    final response = await _dioClient.dio.put<Map<String, dynamic>>(
      '${ApiConstants.adminCoupons}/$id',
      data: coupon.toRequestJson(),
    );
    return _parseSingle(response.data);
  }

  @override
  Future<void> delete(int id) async {
    await _dioClient.dio.delete<void>('${ApiConstants.adminCoupons}/$id');
  }

  CouponModel _parseSingle(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Phản hồi mã giảm giá không hợp lệ');
    }
    return CouponModel.fromJson(data);
  }
}
