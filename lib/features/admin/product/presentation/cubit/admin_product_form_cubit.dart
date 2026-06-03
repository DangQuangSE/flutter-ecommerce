import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/update_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/update_product_usecase.dart';

part 'admin_product_form_state.dart';

class AdminProductFormCubit extends Cubit<AdminProductFormState> {
  final CreateProductUseCase _createProduct;
  final UpdateProductUseCase _updateProduct;

  AdminProductFormCubit(this._createProduct, this._updateProduct)
      : super(const AdminProductFormState());

  void nameChanged(String v) => emit(state.copyWith(name: v, clearError: true));
  void descriptionChanged(String v) => emit(state.copyWith(description: v));
  void categoryChanged(int id) => emit(state.copyWith(categoryId: id));
  void brandChanged(int id) => emit(state.copyWith(brandId: id));
  void genderChanged(Gender g) => emit(state.copyWith(gender: g));
  void statusChanged(ProductStatus s) => emit(state.copyWith(status: s));
  void featuredToggled() =>
      emit(state.copyWith(isFeatured: !state.isFeatured));

  void loadForEdit(AdminProductDetailEntity entity) {
    emit(state.copyWith(
      name: entity.name,
      description: entity.description ?? '',
      categoryId: entity.categoryId,
      brandId: entity.brandId,
      gender: entity.gender,
      status: entity.status,
      isFeatured: entity.isFeatured,
      editingId: entity.id,
      isLoadingDetail: false,
      clearError: true,
    ));
  }

  void reset() => emit(const AdminProductFormState());

  Future<void> submit() async {
    if (state.categoryId == null ||
        state.brandId == null ||
        state.gender == null ||
        state.name.trim().isEmpty) {
      emit(state.copyWith(
          errorMessage: 'Vui lòng điền đầy đủ thông tin bắt buộc'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    if (state.editingId == null) {
      final result = await _createProduct(CreateProductParams(
        name: state.name.trim(),
        description:
            state.description.trim().isEmpty ? null : state.description.trim(),
        categoryId: state.categoryId!,
        brandId: state.brandId!,
        gender: state.gender!,
        isFeatured: state.isFeatured,
        status: state.status,
      ));
      _handleResult(result);
    } else {
      final result = await _updateProduct(
        state.editingId!,
        UpdateProductParams(
          name: state.name.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          categoryId: state.categoryId!,
          brandId: state.brandId!,
          gender: state.gender!,
          status: state.status,
          isFeatured: state.isFeatured,
        ),
      );
      _handleResult(result);
    }
  }

  void _handleResult(Result result) {
    switch (result) {
      case Success():
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      case ResultFailure(:final failure):
        emit(state.copyWith(
            isSubmitting: false, errorMessage: failure.message));
    }
  }
}
