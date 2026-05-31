import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/product_repository.dart';
import 'package:flutter_ecommerce/features/product/domain/usecases/get_products_usecase.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase _getProductsUseCase;
  final ProductRepository _productRepository;

  ProductBloc({
    required GetProductsUseCase getProductsUseCase,
    required ProductRepository productRepository,
  })  : _getProductsUseCase = getProductsUseCase,
        _productRepository = productRepository,
        super(const ProductInitial()) {
    on<ProductListRequested>(_onListRequested);
    on<ProductDetailRequested>(_onDetailRequested);
  }

  Future<void> _onListRequested(
    ProductListRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _getProductsUseCase();
    switch (result) {
      case Success(:final data):
        emit(ProductLoaded(data));
      case ResultFailure(:final failure):
        emit(ProductError(failure.message));
    }
  }

  Future<void> _onDetailRequested(
    ProductDetailRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await _productRepository.getProductById(event.productId);
    switch (result) {
      case Success(:final data):
        emit(ProductDetailLoaded(data));
      case ResultFailure(:final failure):
        emit(ProductError(failure.message));
    }
  }
}
