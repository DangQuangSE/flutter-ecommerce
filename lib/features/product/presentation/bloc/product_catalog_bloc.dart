import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_product_catalog_usecase.dart';

part 'product_catalog_event.dart';
part 'product_catalog_state.dart';

class ProductCatalogBloc
    extends Bloc<ProductCatalogEvent, ProductCatalogState> {
  final GetProductCatalogUseCase _getProducts;

  ProductCatalogBloc(this._getProducts) : super(ProductCatalogInitial()) {
    on<ProductCatalogFetch>(_onLoaded);
    on<ProductCatalogRefreshed>(_onRefreshed);
    on<ProductCatalogLoadMore>(_onLoadMore);
    on<ProductCatalogFilterChanged>(_onFilterChanged);
    on<ProductCatalogApplyFilter>(_onApplyFilter);
  }

  Future<void> _onLoaded(
    ProductCatalogFetch event,
    Emitter<ProductCatalogState> emit,
  ) async {
    emit(ProductCatalogLoading());
    final result = await _getProducts(page: 0);
    switch (result) {
      case Success(:final data):
        emit(ProductCatalogLoaded(
          products: data.content,
          hasReachedMax: data.isLast,
          currentPage: 0,
          totalElements: data.totalElements,
        ));
      case ResultFailure(:final failure):
        emit(ProductCatalogError(failure.message));
    }
  }

  Future<void> _onRefreshed(
    ProductCatalogRefreshed event,
    Emitter<ProductCatalogState> emit,
  ) async {
    final current =
        state is ProductCatalogLoaded ? state as ProductCatalogLoaded : null;
    // Signal refresh in progress so stream.firstWhere always fires
    // (even when refreshed data is identical to the current state)
    if (current != null) emit(current.copyWith(isLoadingMore: true));
    final result = await _getProducts(
      page: 0,
      keyword: current?.keyword,
      categoryId: current?.categoryId,
      brandId: current?.brandId,
      gender: current?.gender,
      productSize: current?.productSize,
      color: current?.color,
      minPrice: current?.minPrice,
      maxPrice: current?.maxPrice,
      sort: current?.sort ?? 'id,desc',
    );
    switch (result) {
      case Success(:final data):
        emit(ProductCatalogLoaded(
          products: data.content,
          hasReachedMax: data.isLast,
          currentPage: 0,
          totalElements: data.totalElements,
          keyword: current?.keyword,
          categoryId: current?.categoryId,
          categoryName: current?.categoryName,
          brandId: current?.brandId,
          brandName: current?.brandName,
          gender: current?.gender,
          productSize: current?.productSize,
          color: current?.color,
          minPrice: current?.minPrice,
          maxPrice: current?.maxPrice,
          sort: current?.sort ?? 'id,desc',
        ));
      case ResultFailure(:final failure):
        emit(ProductCatalogError(failure.message));
    }
  }

  Future<void> _onLoadMore(
    ProductCatalogLoadMore event,
    Emitter<ProductCatalogState> emit,
  ) async {
    if (state is! ProductCatalogLoaded) return;
    final current = state as ProductCatalogLoaded;
    // Guard: check current state snapshot — not the time of dispatch
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.currentPage + 1;
    final result = await _getProducts(
      page: nextPage,
      keyword: current.keyword,
      categoryId: current.categoryId,
      brandId: current.brandId,
      gender: current.gender,
      productSize: current.productSize,
      color: current.color,
      minPrice: current.minPrice,
      maxPrice: current.maxPrice,
      sort: current.sort,
    );
    switch (result) {
      case Success(:final data):
        // Discard if filter context changed while request was in flight
        if (state is! ProductCatalogLoaded) return;
        final live = state as ProductCatalogLoaded;
        if (live.keyword != current.keyword ||
            live.categoryId != current.categoryId ||
            live.brandId != current.brandId ||
            live.gender != current.gender ||
            live.productSize != current.productSize ||
            live.color != current.color ||
            live.minPrice != current.minPrice ||
            live.maxPrice != current.maxPrice) return;
        emit(live.copyWith(
          products: [...live.products, ...data.content],
          isLoadingMore: false,
          hasReachedMax: data.isLast,
          currentPage: nextPage,
          totalElements: data.totalElements,
        ));
      case ResultFailure(:final failure):
        emit(current.copyWith(isLoadingMore: false));
        emit(ProductCatalogError(failure.message));
    }
  }

  Future<void> _onFilterChanged(
    ProductCatalogFilterChanged event,
    Emitter<ProductCatalogState> emit,
  ) async {
    final current =
        state is ProductCatalogLoaded ? state as ProductCatalogLoaded : null;

    // Build next filter state
    final nextState = current != null
        ? current.copyWith(
            keyword: event.clearAll || event.clearKeyword ? null : event.keyword,
            categoryId: event.clearAll || event.clearCategoryId ? null : event.categoryId,
            categoryName: event.clearAll || event.clearCategoryId ? null : event.categoryName,
            brandId: event.clearAll || event.clearBrandId ? null : event.brandId,
            brandName: event.clearAll || event.clearBrandId ? null : event.brandName,
            gender: event.clearAll || event.clearGender ? null : event.gender,
            productSize: event.clearAll || event.clearProductSize ? null : event.productSize,
            color: event.clearAll || event.clearColor ? null : event.color,
            minPrice: event.clearAll || event.clearMinPrice ? null : event.minPrice,
            maxPrice: event.clearAll || event.clearMaxPrice ? null : event.maxPrice,
            sort: event.sort,
            clearKeyword: event.clearAll || event.clearKeyword,
            clearCategoryId: event.clearAll || event.clearCategoryId,
            clearBrandId: event.clearAll || event.clearBrandId,
            clearGender: event.clearAll || event.clearGender,
            clearProductSize: event.clearAll || event.clearProductSize,
            clearColor: event.clearAll || event.clearColor,
            clearMinPrice: event.clearAll || event.clearMinPrice,
            clearMaxPrice: event.clearAll || event.clearMaxPrice,
          )
        : ProductCatalogLoaded(
            products: const [],
            keyword: event.keyword,
            categoryId: event.categoryId,
            categoryName: event.categoryName,
            brandId: event.brandId,
            brandName: event.brandName,
            gender: event.gender,
            productSize: event.productSize,
            color: event.color,
            minPrice: event.minPrice,
            maxPrice: event.maxPrice,
            sort: event.sort ?? 'id,desc',
          );

    // silent = true: chip removal — avoid full skeleton flash
    if (!event.silent) {
      emit(ProductCatalogLoading());
    } else {
      emit(nextState.copyWith(isLoadingMore: true));
    }

    final result = await _getProducts(
      page: 0,
      keyword: nextState.keyword,
      categoryId: nextState.categoryId,
      brandId: nextState.brandId,
      gender: nextState.gender,
      productSize: nextState.productSize,
      color: nextState.color,
      minPrice: nextState.minPrice,
      maxPrice: nextState.maxPrice,
      sort: nextState.sort,
    );
    switch (result) {
      case Success(:final data):
        emit(nextState.copyWith(
          products: data.content,
          isLoadingMore: false,
          hasReachedMax: data.isLast,
          currentPage: 0,
          totalElements: data.totalElements,
        ));
      case ResultFailure(:final failure):
        emit(ProductCatalogError(failure.message));
    }
  }

  Future<void> _onApplyFilter(
    ProductCatalogApplyFilter event,
    Emitter<ProductCatalogState> emit,
  ) async {
    final current =
        state is ProductCatalogLoaded ? state as ProductCatalogLoaded : null;
    emit(ProductCatalogLoading());
    final result = await _getProducts(
      page: 0,
      keyword: current?.keyword,
      categoryId: event.categoryId,
      brandId: event.brandId,
      gender: event.gender,
      productSize: event.productSize,
      color: event.color,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      sort: event.sort ?? current?.sort ?? 'id,desc',
    );
    switch (result) {
      case Success(:final data):
        emit(ProductCatalogLoaded(
          products: data.content,
          hasReachedMax: data.isLast,
          currentPage: 0,
          totalElements: data.totalElements,
          keyword: current?.keyword,
          categoryId: event.categoryId,
          categoryName: event.categoryName,
          brandId: event.brandId,
          brandName: event.brandName,
          gender: event.gender,
          productSize: event.productSize,
          color: event.color,
          minPrice: event.minPrice,
          maxPrice: event.maxPrice,
          sort: event.sort ?? current?.sort ?? 'id,desc',
        ));
      case ResultFailure(:final failure):
        emit(ProductCatalogError(failure.message));
    }
  }
}
