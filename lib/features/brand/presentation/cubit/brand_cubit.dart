import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'brand_state.dart';

class BrandCubit extends Cubit<BrandState> {
  final BrandRepository _repository;

  BrandCubit(this._repository) : super(const BrandInitial());

  Future<void> loadBrands({String? search}) async {
    emit(const BrandLoading());
    final result = await _repository.getBrands(search: search);
    switch (result) {
      case Success(:final data):
        emit(BrandLoaded(brands: data));
      case ResultFailure(:final failure):
        emit(BrandError(failure.message));
    }
  }

  Future<void> createBrand(BrandEntity brand) async {
    final currentState = state;
    if (currentState is! BrandLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));
    final result = await _repository.createBrand(brand);
    switch (result) {
      case Success(:final data):
        final updatedList = List<BrandEntity>.from(currentState.brands)
          ..insert(0, data);
        emit(BrandLoaded(
          brands: updatedList,
          message: 'Đã thêm thương hiệu thành công!',
        ));
      case ResultFailure(:final failure):
        emit(BrandError(failure.message));
    }
  }

  Future<void> updateBrand(int id, BrandEntity brand) async {
    final currentState = state;
    if (currentState is! BrandLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));
    final result = await _repository.updateBrand(id, brand);
    switch (result) {
      case Success(:final data):
        final updatedList =
            currentState.brands.map((b) => b.id == id ? data : b).toList();
        emit(BrandLoaded(
          brands: updatedList,
          message: 'Đã cập nhật thương hiệu thành công!',
        ));
      case ResultFailure(:final failure):
        emit(BrandError(failure.message));
    }
  }

  Future<void> deleteBrand(int id) async {
    final currentState = state;
    if (currentState is! BrandLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));
    final result = await _repository.deleteBrand(id);
    switch (result) {
      case Success():
        final updatedList =
            currentState.brands.where((brand) => brand.id != id).toList();
        emit(BrandLoaded(
          brands: updatedList,
          message: 'Đã xóa thương hiệu thành công!',
        ));
      case ResultFailure(:final failure):
        emit(BrandError(failure.message));
    }
  }

  Future<void> toggleBrandStatus(int id, bool isActive) async {
    final currentState = state;
    if (currentState is! BrandLoaded) return;

    final updatedBrands = currentState.brands.map((brand) {
      if (brand.id == id) {
        return brand.copyWith(isActive: isActive);
      }
      return brand;
    }).toList();

    emit(currentState.copyWith(brands: updatedBrands));

    final result = await _repository.updateBrandStatus(id, isActive);
    switch (result) {
      case Success():
        emit(BrandLoaded(
          brands: updatedBrands,
          message: 'Đã cập nhật trạng thái thương hiệu!',
        ));
      case ResultFailure(:final failure):
        final rolledBackBrands = currentState.brands.map((brand) {
          if (brand.id == id) {
            return brand.copyWith(isActive: !isActive);
          }
          return brand;
        }).toList();
        emit(BrandLoaded(brands: rolledBackBrands));
        emit(BrandError(failure.message));
    }
  }
}
