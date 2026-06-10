import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/update_product_params.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/create_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/delete_product_usecase.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';

part 'admin_product_form_state.dart';

class AdminProductFormCubit extends Cubit<AdminProductFormState> {
  final CreateProductUseCase _createProduct;
  final UpdateAdminProductUseCase _updateProduct;
  final DeleteAdminProductUseCase _deleteProduct;
  final CategoryRepository _categoryRepository;
  final BrandRepository _brandRepository;

  AdminProductFormCubit(
    this._createProduct,
    this._updateProduct,
    this._deleteProduct,
    this._categoryRepository,
    this._brandRepository,
  ) : super(const AdminProductFormState());

  void nameChanged(String v) => emit(state.copyWith(name: v, clearError: true));
  void descriptionChanged(String v) => emit(state.copyWith(description: v));
  void categoryChanged(int id) => emit(state.copyWith(categoryId: id));
  void brandChanged(int id) => emit(state.copyWith(brandId: id));
  void genderChanged(Gender g) => emit(state.copyWith(gender: g));
  void statusChanged(ProductStatus s) => emit(state.copyWith(status: s));
  void featuredToggled() => emit(state.copyWith(isFeatured: !state.isFeatured));

  void goBack() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void advanceToStep(int step) => emit(state.copyWith(currentStep: step));

  void completeForm() => emit(state.copyWith(isSuccess: true));

  Future<void> loadDropdowns() async {
    emit(state.copyWith(
      dropdownStatus: DropdownStatus.loading,
      clearDropdownError: true,
    ));
    try {
      // Launch both requests in parallel, then await each result.
      final catFuture = _categoryRepository.getTree();
      final brandFuture = _brandRepository.getBrands(size: 100);
      final catResult = await catFuture;
      final brandResult = await brandFuture;

      if (catResult is Success<List<CategoryTreeNode>> &&
          brandResult is Success<List<BrandEntity>>) {
        emit(state.copyWith(
          dropdownStatus: DropdownStatus.loaded,
          categories: catResult.data,
          brands: brandResult.data.where((b) => b.id != null).toList(),
        ));
      } else {
        final msg = catResult is ResultFailure<List<CategoryTreeNode>>
            ? catResult.failure.message
            : (brandResult as ResultFailure<List<BrandEntity>>).failure.message;
        emit(state.copyWith(
          dropdownStatus: DropdownStatus.error,
          dropdownErrorMessage: msg,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        dropdownStatus: DropdownStatus.error,
        dropdownErrorMessage: 'Không thể tải danh sách. Vui lòng thử lại.',
      ));
    }
  }

  Future<void> retryDropdowns() => loadDropdowns();

  Future<void> submitStep1() async {
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
      switch (result) {
        case Success(:final data):
          // CRITICAL: do NOT emit isSuccess:true — reserved for completeForm() in Step 3.
          emit(state.copyWith(
            isSubmitting: false,
            createdProductId: data.id,
            currentStep: 1,
          ));
        case ResultFailure(:final failure):
          emit(state.copyWith(
              isSubmitting: false, errorMessage: failure.message));
      }
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
      switch (result) {
        case Success():
          // CRITICAL: do NOT emit isSuccess:true here.
          emit(state.copyWith(isSubmitting: false, currentStep: 1));
        case ResultFailure(:final failure):
          emit(state.copyWith(
              isSubmitting: false, errorMessage: failure.message));
      }
    }
  }

  Future<void> deleteCreatedProduct() async {
    final id = state.createdProductId;
    if (id == null) return;
    final result = await _deleteProduct(id);
    if (result case ResultFailure(:final failure)) {
      emit(state.copyWith(errorMessage: 'Không thể xóa sản phẩm: ${failure.message}'));
    }
  }

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

}
