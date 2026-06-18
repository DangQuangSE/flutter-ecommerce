import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_list_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/get_admin_products_usecase.dart';

part 'admin_product_list_event.dart';
part 'admin_product_list_state.dart';

class AdminProductListBloc
    extends Bloc<AdminProductListEvent, AdminProductListState> {
  final GetAdminProductsUseCase _getProducts;
  final DeleteAdminProductUseCase _deleteProduct;

  AdminProductListBloc(this._getProducts, this._deleteProduct)
      : super(AdminProductListInitial()) {
    on<AdminProductListLoaded>(_onLoaded);
    on<AdminProductListRefreshed>(_onRefreshed);
    on<AdminProductListLoadedMore>(_onLoadedMore);
    on<AdminProductListFiltered>(_onFiltered);
    on<AdminProductDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(
    AdminProductListLoaded event,
    Emitter<AdminProductListState> emit,
  ) async {
    emit(AdminProductListLoading());
    final result = await _getProducts(page: 0);
    switch (result) {
      case Success(:final data):
        emit(AdminProductListSuccess(
          products: data.content,
          hasReachedMax: data.isLast,
          currentPage: 0,
          totalElements: data.totalElements,
        ));
      case ResultFailure(:final failure):
        emit(AdminProductListFailure(failure.message));
    }
  }

  Future<void> _onRefreshed(
    AdminProductListRefreshed event,
    Emitter<AdminProductListState> emit,
  ) async {
    final current = state is AdminProductListSuccess
        ? state as AdminProductListSuccess
        : null;
    final result = await _getProducts(
      page: 0,
      keyword: current?.keyword,
      status: current?.status,
      categoryId: current?.categoryId,
      brandId: current?.brandId,
      gender: current?.gender,
      isFeatured: current?.isFeatured,
    );
    switch (result) {
      case Success(:final data):
        emit(AdminProductListSuccess(
          products: data.content,
          hasReachedMax: data.isLast,
          currentPage: 0,
          totalElements: data.totalElements,
          keyword: current?.keyword,
          status: current?.status,
          categoryId: current?.categoryId,
          brandId: current?.brandId,
          gender: current?.gender,
          isFeatured: current?.isFeatured,
        ));
      case ResultFailure(:final failure):
        emit(AdminProductListFailure(failure.message));
    }
  }

  Future<void> _onLoadedMore(
    AdminProductListLoadedMore event,
    Emitter<AdminProductListState> emit,
  ) async {
    if (state is! AdminProductListSuccess) return;
    final current = state as AdminProductListSuccess;
    if (current.hasReachedMax || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.currentPage + 1;
    final result = await _getProducts(
      page: nextPage,
      keyword: current.keyword,
      status: current.status,
      categoryId: current.categoryId,
      brandId: current.brandId,
      gender: current.gender,
      isFeatured: current.isFeatured,
    );
    switch (result) {
      case Success(:final data):
        emit(current.copyWith(
          products: [...current.products, ...data.content],
          isLoadingMore: false,
          hasReachedMax: data.isLast,
          currentPage: nextPage,
          totalElements: data.totalElements,
        ));
      case ResultFailure(:final failure):
        emit(current.copyWith(isLoadingMore: false));
        emit(AdminProductListFailure(failure.message));
    }
  }

  Future<void> _onFiltered(
    AdminProductListFiltered event,
    Emitter<AdminProductListState> emit,
  ) async {
    emit(AdminProductListLoading());
    final result = await _getProducts(
      page: 0,
      keyword: event.keyword,
      status: event.status,
      categoryId: event.categoryId,
      brandId: event.brandId,
      gender: event.gender,
      isFeatured: event.isFeatured,
    );
    switch (result) {
      case Success(:final data):
        emit(AdminProductListSuccess(
          products: data.content,
          hasReachedMax: data.isLast,
          currentPage: 0,
          totalElements: data.totalElements,
          keyword: event.keyword,
          status: event.status,
          categoryId: event.categoryId,
          brandId: event.brandId,
          gender: event.gender,
          isFeatured: event.isFeatured,
        ));
      case ResultFailure(:final failure):
        emit(AdminProductListFailure(failure.message));
    }
  }

  Future<void> _onDeleted(
    AdminProductDeleted event,
    Emitter<AdminProductListState> emit,
  ) async {
    if (state is! AdminProductListSuccess) return;
    final current = state as AdminProductListSuccess;
    final result = await _deleteProduct(event.id);
    switch (result) {
      case Success():
        final updated =
            current.products.where((p) => p.id != event.id).toList();
        emit(current.copyWith(
          products: updated,
          totalElements: current.totalElements - 1,
        ));
      case ResultFailure(:final failure):
        emit(AdminProductListFailure(failure.message));
    }
  }
}
