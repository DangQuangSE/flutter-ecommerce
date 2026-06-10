part of 'admin_product_form_cubit.dart';

enum DropdownStatus { idle, loading, loaded, error }

class AdminProductFormState extends Equatable {
  final String name;
  final String description;
  final int? categoryId;
  final int? brandId;
  final Gender? gender;
  final ProductStatus status;
  final bool isFeatured;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isLoadingDetail;
  final String? errorMessage;
  final int? editingId;
  // multi-step fields
  final int currentStep;
  final DropdownStatus dropdownStatus;
  final List<CategoryTreeNode> categories;
  final List<BrandEntity> brands;
  final int? createdProductId;
  final String? dropdownErrorMessage;

  const AdminProductFormState({
    this.name = '',
    this.description = '',
    this.categoryId,
    this.brandId,
    this.gender,
    this.status = ProductStatus.active,
    this.isFeatured = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isLoadingDetail = false,
    this.errorMessage,
    this.editingId,
    this.currentStep = 0,
    this.dropdownStatus = DropdownStatus.idle,
    this.categories = const [],
    this.brands = const [],
    this.createdProductId,
    this.dropdownErrorMessage,
  });

  AdminProductFormState copyWith({
    String? name,
    String? description,
    int? categoryId,
    int? brandId,
    Gender? gender,
    ProductStatus? status,
    bool? isFeatured,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isLoadingDetail,
    String? errorMessage,
    int? editingId,
    bool clearError = false,
    int? currentStep,
    DropdownStatus? dropdownStatus,
    List<CategoryTreeNode>? categories,
    List<BrandEntity>? brands,
    int? createdProductId,
    bool clearCreatedProductId = false,
    String? dropdownErrorMessage,
    bool clearDropdownError = false,
  }) {
    return AdminProductFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      editingId: editingId ?? this.editingId,
      currentStep: currentStep ?? this.currentStep,
      dropdownStatus: dropdownStatus ?? this.dropdownStatus,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      createdProductId: clearCreatedProductId ? null : createdProductId ?? this.createdProductId,
      dropdownErrorMessage: clearDropdownError ? null : dropdownErrorMessage ?? this.dropdownErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        categoryId,
        brandId,
        gender,
        status,
        isFeatured,
        isSubmitting,
        isSuccess,
        isLoadingDetail,
        errorMessage,
        editingId,
        currentStep,
        dropdownStatus,
        categories,
        brands,
        createdProductId,
        dropdownErrorMessage,
      ];
}
