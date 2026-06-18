import 'package:flutter_ecommerce/core/models/paged_response.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/admin_product_detail_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/admin_product_list_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_create_request_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_update_request_model.dart';

abstract interface class AdminProductDatasource {
  Future<PagedResponse<AdminProductListModel>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    String? gender,
    String? status,
    bool? isFeatured,
    int page = 0,
    int size = 20,
  });
  Future<AdminProductDetailModel> getProductById(int id);
  Future<AdminProductDetailModel> createProduct(
      ProductCreateRequestModel request);
  Future<AdminProductDetailModel> updateProduct(
      int id, ProductUpdateRequestModel request);
  Future<void> deleteProduct(int id);
  Future<void> restoreProduct(int id);
}
