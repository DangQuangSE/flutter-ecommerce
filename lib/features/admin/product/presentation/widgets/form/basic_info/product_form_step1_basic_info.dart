import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/form/basic_info/product_basic_info_widgets.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';

class ProductFormStep1BasicInfo extends StatefulWidget {
  final AdminProductFormState state;
  final AdminProductFormCubit cubit;

  const ProductFormStep1BasicInfo({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  State<ProductFormStep1BasicInfo> createState() =>
      _ProductFormStep1BasicInfoState();
}

class _ProductFormStep1BasicInfoState extends State<ProductFormStep1BasicInfo> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  late List<ProductCategoryOption> _flatCategories;

  List<ProductCategoryOption> _flattenCategories(
    List<CategoryTreeNode> nodes, [
    int depth = 0,
  ]) {
    final result = <ProductCategoryOption>[];
    for (final node in nodes) {
      final prefix = depth > 0
          ? '${AppStrings.adminProductCategoryDepthPrefix * depth} '
          : '';
      result.add((id: node.id, label: '$prefix${node.name}'));
      result.addAll(_flattenCategories(node.children, depth + 1));
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
    _descController = TextEditingController(text: widget.state.description);
    _flatCategories = _flattenCategories(widget.state.categories);
  }

  @override
  void didUpdateWidget(ProductFormStep1BasicInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.categories != oldWidget.state.categories) {
      _flatCategories = _flattenCategories(widget.state.categories);
    }
    // Sync controllers when edit-mode data loads (cubit state diverges from controller).
    // copyWith preserves cursor position; the condition prevents spurious syncs during typing.
    if (_nameController.text != widget.state.name) {
      _nameController.value =
          _nameController.value.copyWith(text: widget.state.name);
    }
    if (_descController.text != widget.state.description) {
      _descController.value =
          _descController.value.copyWith(text: widget.state.description);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = widget.cubit;
    final flatCategories = _flatCategories;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductBasicNameField(
              controller: _nameController,
              onChanged: cubit.nameChanged,
            ),
            const SizedBox(height: AppSizes.paddingMd),
            ProductBasicDescriptionField(
              controller: _descController,
              onChanged: cubit.descriptionChanged,
            ),
            const SizedBox(height: AppSizes.paddingMd),
            ProductBasicCategoryDropdown(
              selectedCategoryId: state.categoryId,
              categories: flatCategories,
              onChanged: cubit.categoryChanged,
            ),
            const SizedBox(height: AppSizes.paddingMd),
            ProductBasicBrandDropdown(
              state: state,
              onChanged: cubit.brandChanged,
            ),
            const SizedBox(height: AppSizes.paddingMd),
            ProductBasicSizeGroupDropdown(
              state: state,
              onChanged: cubit.sizeGroupChanged,
            ),
            const SizedBox(height: AppSizes.paddingMd),
            ProductBasicGenderDropdown(
              gender: state.gender,
              onChanged: cubit.genderChanged,
            ),
            const SizedBox(height: AppSizes.paddingMd),
            ProductBasicStatusDropdown(
              status: state.status,
              onChanged: cubit.statusChanged,
            ),
            const SizedBox(height: AppSizes.paddingSm),
            ProductBasicFeaturedSwitch(
              value: state.isFeatured,
              onToggle: cubit.featuredToggled,
            ),
            const SizedBox(height: AppSizes.paddingXl),
            ProductBasicNextButton(
              isSubmitting: state.isSubmitting,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  cubit.submitStep1();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
