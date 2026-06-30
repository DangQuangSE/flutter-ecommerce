import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/product_color_repository.dart';
import 'product_color_state.dart';

class ProductColorCubit extends Cubit<ProductColorState> {
  final ProductColorRepository _repository;

  ProductColorCubit(this._repository) : super(const ProductColorInitial());

  Future<void> loadColors() async {
    emit(const ProductColorLoading());
    final result = await _repository.getColors();
    switch (result) {
      case Success(:final data):
        emit(ProductColorLoaded(colors: data));
      case ResultFailure(:final failure):
        emit(ProductColorError(failure.message));
    }
  }

  Future<void> createColor(ProductColorEntity color) async {
    final currentState = state;
    if (currentState is ProductColorLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.createColor(color);
      switch (result) {
        case Success(:final data):
          final updatedList = List<ProductColorEntity>.from(currentState.colors)
            ..insert(0, data);
          emit(ProductColorLoaded(
            colors: updatedList,
            message: AppStrings.adminColorProductCreated,
          ));
        case ResultFailure(:final failure):
          emit(ProductColorError(failure.message));
      }
    }
  }

  Future<void> updateColor(int id, ProductColorEntity color) async {
    final currentState = state;
    if (currentState is ProductColorLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.updateColor(id, color);
      switch (result) {
        case Success(:final data):
          final updatedList =
              currentState.colors.map((c) => c.id == id ? data : c).toList();
          emit(ProductColorLoaded(
            colors: updatedList,
            message: AppStrings.adminColorProductUpdated,
          ));
        case ResultFailure(:final failure):
          emit(ProductColorError(failure.message));
      }
    }
  }

  Future<void> deleteColor(int id) async {
    final currentState = state;
    if (currentState is ProductColorLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.deleteColor(id);
      switch (result) {
        case Success():
          final updatedList =
              currentState.colors.where((c) => c.id != id).toList();
          emit(ProductColorLoaded(
            colors: updatedList,
            message: AppStrings.adminColorProductDeleted,
          ));
        case ResultFailure(:final failure):
          emit(ProductColorError(failure.message));
      }
    }
  }
}
