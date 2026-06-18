import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/features/category/data/network/category_api_client.dart';
import 'package:flutter_ecommerce/features/category/data/models/category_model.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_page.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';

abstract interface class CategoryRemoteDataSource {
  Future<CategoryPage> getCategories({int page, int size, String? search});
  Future<CategoryModel> getBySlug(String slug);
  Future<List<CategoryTreeNode>> getTree();
  Future<CategoryModel> create(CategoryModel category);
  Future<CategoryModel> update(int id, CategoryModel category);
  Future<void> delete(int id);
  Future<void> updateStatus(int id, {required bool isActive});
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final CategoryApiClient _client;

  const CategoryRemoteDataSourceImpl(this._client);

  // Public (read) endpoint
  static const String _categories = '/api/categories';
  // Admin (write) endpoints — require a Bearer token
  static const String _adminCategories = '/api/admin/categories';

  @override
  Future<CategoryPage> getCategories({
    int page = 0,
    int size = 20,
    String? search,
  }) async {
    final response = await _client.dio.get(
      _categories,
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = (response.data as Map<String, dynamic>)['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Phản hồi danh sách danh mục không hợp lệ');
    }
    final content = (data['content'] as List<dynamic>? ?? [])
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CategoryPage(
      items: content,
      page: (data['number'] as num?)?.toInt() ?? page,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      totalElements: (data['totalElements'] as num?)?.toInt() ?? content.length,
      isLast: data['last'] as bool? ?? true,
    );
  }

  @override
  Future<CategoryModel> getBySlug(String slug) async {
    final response = await _client.dio.get('$_categories/$slug');
    return _parseSingle(response.data);
  }

  @override
  Future<List<CategoryTreeNode>> getTree() async {
    final response = await _client.dio.get('$_categories/tree');
    final data = (response.data as Map<String, dynamic>)['data'];
    if (data is! List) {
      throw const ParseException('Phản hồi cây danh mục không hợp lệ');
    }
    return data.map((e) => _parseTreeNode(e as Map<String, dynamic>)).toList();
  }

  CategoryTreeNode _parseTreeNode(Map<String, dynamic> json) {
    return CategoryTreeNode(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      imageUrl: json['imageUrl'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      isCustomizable: json['customizable'] as bool? ?? false,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((c) => _parseTreeNode(c as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    final response = await _client.dio.post(
      _adminCategories,
      data: category.toRequestJson(),
    );
    return _parseSingle(response.data);
  }

  @override
  Future<CategoryModel> update(int id, CategoryModel category) async {
    final response = await _client.dio.put(
      '$_adminCategories/$id',
      data: category.toRequestJson(),
    );
    return _parseSingle(response.data);
  }

  @override
  Future<void> delete(int id) async {
    await _client.dio.delete('$_adminCategories/$id');
  }

  @override
  Future<void> updateStatus(int id, {required bool isActive}) async {
    await _client.dio.patch(
      '$_adminCategories/$id/status',
      queryParameters: {'isActive': isActive},
    );
  }

  CategoryModel _parseSingle(dynamic body) {
    final data = (body as Map<String, dynamic>)['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Phản hồi danh mục không hợp lệ');
    }
    return CategoryModel.fromJson(data);
  }
}
