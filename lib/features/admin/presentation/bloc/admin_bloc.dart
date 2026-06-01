import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_stats_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/add_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/delete_product_usecase.dart';

import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAdminStatsUseCase _getAdminStatsUseCase;
  final GetProductsUseCase _getProductsUseCase;
  final AddProductUseCase _addProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  AdminBloc({
    required GetAdminStatsUseCase getAdminStatsUseCase,
    required GetProductsUseCase getProductsUseCase,
    required AddProductUseCase addProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  })  : _getAdminStatsUseCase = getAdminStatsUseCase,
        _getProductsUseCase = getProductsUseCase,
        _addProductUseCase = addProductUseCase,
        _updateProductUseCase = updateProductUseCase,
        _deleteProductUseCase = deleteProductUseCase,
        super(const AdminInitial()) {
    on<AdminStatsRequested>(_onStatsRequested);
    on<AdminProductAdded>(_onProductAdded);
    on<AdminProductUpdated>(_onProductUpdated);
    on<AdminProductDeleted>(_onProductDeleted);
  }

  Future<void> _onStatsRequested(
    AdminStatsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    
    final statsResult = await _getAdminStatsUseCase();
    final productsResult = await _getProductsUseCase();

    if (statsResult is Success && productsResult is Success) {
      emit(AdminLoaded(
        stats: (statsResult as Success).data,
        products: (productsResult as Success).data,
      ));
    } else if (statsResult is ResultFailure) {
      emit(AdminError((statsResult as ResultFailure).failure.message));
    } else if (productsResult is ResultFailure) {
      emit(AdminError((productsResult as ResultFailure).failure.message));
    } else {
      emit(const AdminError('Đã xảy ra lỗi không xác định.'));
    }
  }

  Future<void> _onProductAdded(
    AdminProductAdded event,
    Emitter<AdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final result = await _addProductUseCase(event.product);
      switch (result) {
        case Success(:final data):
          final updatedProducts = List.of(currentState.products)..add(data);
          emit(currentState.copyWith(
            products: updatedProducts,
            message: 'Đã thêm sản phẩm thành công!',
          ));
        case ResultFailure(:final failure):
          emit(AdminError(failure.message));
      }
    }
  }

  Future<void> _onProductUpdated(
    AdminProductUpdated event,
    Emitter<AdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final result = await _updateProductUseCase(event.product);
      switch (result) {
        case Success(:final data):
          final updatedProducts = currentState.products.map((p) {
            return p.id == data.id ? data : p;
          }).toList();
          emit(currentState.copyWith(
            products: updatedProducts,
            message: 'Đã cập nhật sản phẩm thành công!',
          ));
        case ResultFailure(:final failure):
          emit(AdminError(failure.message));
      }
    }
  }

  Future<void> _onProductDeleted(
    AdminProductDeleted event,
    Emitter<AdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final result = await _deleteProductUseCase(event.productId);
      switch (result) {
        case Success(:final data):
          if (data) {
            final updatedProducts = currentState.products
                .where((p) => p.id != event.productId)
                .toList();
            emit(currentState.copyWith(
              products: updatedProducts,
              message: 'Đã xóa sản phẩm thành công!',
            ));
          } else {
            emit(currentState.copyWith(message: 'Không tìm thấy sản phẩm để xóa.'));
          }
        case ResultFailure(:final failure):
          emit(AdminError(failure.message));
      }
    }
  }
}
