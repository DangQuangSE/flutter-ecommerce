# Phase 1: Data Layer

## Requirements
Deliver a complete, paginated, filter-capable product data pipeline by replacing the existing stub datasource with a fully specified interface + implementation, and introduce the `ProductCatalogModel` that maps the backend `ProductListResponse` shape. Category and brand data access already exist and require no changes.

## Steps
1. **Define the new `ProductCatalogModel`** inside `lib/features/product/data/models/`. Map all fields from the backend `ProductListResponse`: `id`, `name`, `slug`, `sku`, `basePrice`, `originalPrice`, `salePrice`, `imageUrl`, `categoryName`, `brandName`, `totalStock`, `averageRating`, `status`, `gender`, `availableSizes`, `availableColors`. Use `fromJson` with safe null coercion (same style as `AdminProductListModel`). Include a `toEntity()` method that returns `ProductCatalogEntity` (defined in Phase 2).

2. **Extend `product_remote_datasource.dart`** (the existing abstract interface) — add a `getCatalogProducts` method accepting all filter params plus `page` and `size=12`. **CRITICAL: do NOT remove existing CRUD method signatures** (`getProducts`, `getProductById`, `addProduct`, `updateProduct`, `deleteProduct`). `ProductBloc`, `GetProductsUseCase`, and `AdminBloc` all depend on these signatures — removing them causes a compile-time failure. The new interface is purely additive.

3. **Replace `product_remote_datasource_impl.dart`** with an implementation of the new interface. Call `GET /api/products` via `_dioClient.dio.get`, passing all non-null filter params as query parameters. Unwrap `response.data['data']` and parse the result into `PagedResponse<ProductCatalogModel>` using the existing `PagedResponse.fromJson` factory. Catch `DioException` and rethrow as `NetworkException` (same pattern as `AdminProductDatasourceImpl`).
   **BLOCKING GATE**: Before finalising the `fromJson` impl, verify the actual backend response envelope shape with one real API call to `GET /api/products?page=0&size=1`. Confirm that `response.data['data']` contains keys `totalPages`, `totalElements`, `number`, `size`, and `content`. If any key is absent or null on empty results, add safe-cast fallbacks: `(json['totalPages'] as num?)?.toInt() ?? 0` for all int fields in `PagedResponse.fromJson`.

4. **Extend `product_repository_impl.dart`** — add the `getCatalogProducts` implementation that wraps the datasource call in a `try/catch` returning `Result<PagedResponse<ProductCatalogEntity>>` (mirrors `BrandRepositoryImpl`). **Keep all existing CRUD method implementations** (`getProducts`, `getProductById`, `addProduct`, `updateProduct`, `deleteProduct`) as-is — do not remove them. Update the existing `product_repository.dart` abstract to declare `getCatalogProducts` as an additional method.

5. **Verify category and brand data access** — confirm `CategoryRepository.getTree()` and `BrandRepository.getBrands()` are already registered as `LazySingleton` in `injection_container.dart` (they are, per existing code). No new datasource or repository files needed for categories or brands.

## Success Criteria
- `ProductCatalogModel.fromJson` correctly parses a sample `ProductListResponse` JSON with all 16 fields populated, including list fields `availableSizes` and `availableColors`
- `ProductRemoteDataSourceImpl.getCatalogProducts` builds the correct query parameter map — a call with `keyword="shirt"`, `categoryId=2`, `page=1`, `size=12` produces `?keyword=shirt&categoryId=2&page=1&size=12` with no null-valued keys included
- `ProductRepositoryImpl.getCatalogProducts` returns `Success(PagedResponse)` on a valid response and `ResultFailure(NetworkFailure)` on a `DioException`
- Existing `ProductBloc` (admin CRUD path) still compiles — replacing the datasource interface must not break the existing `ProductRemoteDataSource` registrations in DI

## Risks
- Replacing the datasource interface breaks `ProductBloc` and `ProductRepository` which still reference the old CRUD methods: update both `product_repository.dart` and `product_repository_impl.dart` together, and verify `ProductBloc` in `product_bloc.dart` does not call any removed methods.
- `response.data['data']` unwrap differs from the admin datasource which returns `response.data` directly — confirm backend response envelope shape with a real API call before finalising the impl.
