import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/domain/repositories/shop_repository.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final ShopRepository _repository;

  ShopCubit(this._repository) : super(const ShopInitial());

  Future<void> loadShop() async {
    emit(const ShopLoading());
    final result = await _repository.getShop();
    switch (result) {
      case Success(:final data):
        emit(ShopLoaded(data));
      case ResultFailure(:final failure):
        emit(ShopError(failure.message));
    }
  }

  /// Returns `null` on success (also emits [ShopLoaded] with updated data),
  /// or the error message string when the update fails.
  Future<String?> updateShop(ShopEntity draft) async {
    final result = await _repository.updateShop(draft);
    switch (result) {
      case Success(:final data):
        emit(ShopLoaded(data));
        return null;
      case ResultFailure(:final failure):
        return failure.message;
    }
  }

  /// Uploads [file] as a shop image of the given [type] ('logo' or 'cover').
  /// Returns `(url: url, error: null)` on success or `(url: null, error: message)` on failure.
  Future<({String? url, String? error})> uploadShopImageWithUrl(
    File file,
    String type,
  ) async {
    final result = await _repository.uploadShopImage(file, type);
    switch (result) {
      case Success(:final data):
        return (url: data, error: null);
      case ResultFailure(:final failure):
        return (url: null, error: failure.message);
    }
  }
}
