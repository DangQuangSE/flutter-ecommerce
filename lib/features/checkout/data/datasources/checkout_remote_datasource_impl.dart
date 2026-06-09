import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/order_request_model.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/order_response_model.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/vnpay_create_response_model.dart';
import 'package:flutter_ecommerce/features/checkout/data/models/vnpay_verify_response_model.dart';

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final DioClient _dioClient;

  const CheckoutRemoteDataSourceImpl(this._dioClient);

  @override
  Future<OrderResponseModel> placeOrder(OrderRequestModel request) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.orders,
      data: request.toJson(),
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return OrderResponseModel.fromJson(data);
  }

  @override
  Future<VnpayCreateResponseModel> createVnpayPayment(int orderId) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiConstants.vnpayCreate,
      data: {'orderId': orderId},
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return VnpayCreateResponseModel.fromJson(data);
  }

  @override
  Future<VnpayVerifyResponseModel> verifyVnpayPayment(int orderId) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      ApiConstants.vnpayVerify(orderId),
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return VnpayVerifyResponseModel.fromJson(data);
  }
}
