import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_variants_batch_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_variant_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/update_variant_usecase.dart';

part 'admin_product_variant_state.dart';

class AdminProductVariantCubit extends Cubit<AdminProductVariantState> {
  final CreateVariantUseCase _createVariant;
  final CreateVariantsBatchUseCase _createVariantsBatch;
  final UpdateVariantUseCase _updateVariant;
  final DeleteVariantUseCase _deleteVariant;

  AdminProductVariantCubit(this._createVariant, this._createVariantsBatch,
      this._updateVariant, this._deleteVariant)
      : super(AdminProductVariantInitial());

  void loadFromDetail(List<ProductVariantEntity> variants) {
    emit(AdminProductVariantSuccess(variants));
  }

  Future<void> createVariant(int productId, CreateVariantParams params) async {
    final current = _currentVariants;
    emit(AdminProductVariantLoading());
    final result = await _createVariant(productId, params);
    switch (result) {
      case Success(:final data):
        emit(AdminProductVariantSuccess([...current, data]));
      case ResultFailure(:final failure):
        emit(AdminProductVariantSuccess(current));
        emit(AdminProductVariantFailure(failure.message));
    }
  }

  Future<void> createVariantsBatch(
      int productId, List<CreateVariantParams> params) async {
    final current = _currentVariants;
    emit(AdminProductVariantLoading());
    final result = await _createVariantsBatch(productId, params);
    switch (result) {
      case Success(:final data):
        emit(AdminProductVariantSuccess([...current, ...data]));
      case ResultFailure(:final failure):
        emit(AdminProductVariantSuccess(current));
        emit(AdminProductVariantFailure(failure.message));
    }
  }

  Future<void> updateVariant(int variantId, CreateVariantParams params) async {
    final current = _currentVariants;
    emit(AdminProductVariantLoading());
    final result = await _updateVariant(variantId, params);
    switch (result) {
      case Success(:final data):
        final updated = current
            .map((v) => v.id == variantId ? data : v)
            .toList();
        emit(AdminProductVariantSuccess(updated));
      case ResultFailure(:final failure):
        emit(AdminProductVariantSuccess(current));
        emit(AdminProductVariantFailure(failure.message));
    }
  }

  Future<void> deleteVariant(int variantId) async {
    final current = _currentVariants;
    emit(AdminProductVariantLoading());
    final result = await _deleteVariant(variantId);
    switch (result) {
      case Success():
        emit(AdminProductVariantSuccess(
            current.where((v) => v.id != variantId).toList()));
      case ResultFailure(:final failure):
        emit(AdminProductVariantSuccess(current));
        emit(AdminProductVariantFailure(failure.message));
    }
  }

  List<ProductVariantEntity> get _currentVariants {
    final s = state;
    return s is AdminProductVariantSuccess ? s.variants : [];
  }
}
