import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
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

  Future<void> addItem({
    required int variantId,
    required int quantity,
    bool isReplace = false,
    int? customDesignId,
  }) async {
    emit(const CartLoading());
    final result = await _repository.addOrUpdateItem(
      variantId: variantId,
      quantity: quantity,
      isReplace: isReplace,
      customDesignId: customDesignId,
    );
    switch (result) {
      case Success(:final data):
        emit(CartLoaded(data));
      case ResultFailure(:final failure):
        emit(CartError(failure.message));
    }
  }

  Future<void> updateQuantity({
    required int variantId,
    required int quantity,
  }) async {
    await addItem(
      variantId: variantId,
      quantity: quantity,
      isReplace: true,
    );
  }

  Future<void> removeItem(int itemId) async {
    emit(const CartLoading());
    final result = await _repository.removeItem(itemId);
    switch (result) {
      case Success(:final data):
        emit(CartLoaded(data));
      case ResultFailure(:final failure):
        emit(CartError(failure.message));
    }
  }

  Future<void> replaceWithCustomDesign({
    required int variantId,
    required int quantity,
    required int customDesignId,
  }) async {
    int? oldItemId;
    final current = state;
    if (current is CartLoaded) {
      final candidates = current.items.where(
        (item) => item.variantId == variantId && item.customDesignId == null,
      );
      if (candidates.isNotEmpty) oldItemId = candidates.first.itemId;
    }
    await addItem(variantId: variantId, quantity: quantity, isReplace: true, customDesignId: customDesignId);
    if (oldItemId != null) await removeItem(oldItemId);
  }

  void clearCart() {
    emit(const CartLoaded([]));
  }
}
