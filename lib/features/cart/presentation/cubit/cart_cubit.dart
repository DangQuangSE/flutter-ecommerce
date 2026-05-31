import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;

  CartCubit(this._repository) : super(const CartInitial());

  Future<void> loadCart() async {
    emit(const CartLoading());
    final result = await _repository.getCartItems();
    switch (result) {
      case Success(:final data):
        emit(CartLoaded(data));
      case ResultFailure(:final failure):
        emit(CartError(failure.message));
    }
  }

  Future<void> addItem(CartItemEntity item) async {
    await _repository.addItem(item);
    await loadCart();
  }

  Future<void> removeItem(String productId) async {
    await _repository.removeItem(productId);
    await loadCart();
  }

  Future<void> clearCart() async {
    await _repository.clearCart();
    emit(const CartLoaded([]));
  }
}
