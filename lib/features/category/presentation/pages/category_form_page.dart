import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/form/category_form_app_bar.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/form/category_form_fields.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/form/category_submit_button.dart';

class CategoryFormPage extends StatefulWidget {
  final CategoryEntity? category;
  final List<CategoryEntity> parents;

  const CategoryFormPage({
    super.key,
    this.category,
    this.parents = const [],
  });

  bool get isEditing => category != null;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _displayOrderController;

  int? _parentId;
  late bool _isActive;
  late bool _isCustomizable;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _descriptionController =
        TextEditingController(text: category?.description ?? '');
    _imageUrlController = TextEditingController(text: category?.imageUrl ?? '');
    _displayOrderController = TextEditingController(
      text: category?.displayOrder?.toString() ?? '',
    );
    _parentId = category?.parentId;
    _isActive = category?.isActive ?? true;
    _isCustomizable = category?.isCustomizable ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  List<CategoryEntity> get _parentOptions => widget.parents
      .where((parent) => parent.id != null && parent.id != widget.category?.id)
      .toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final draft = CategoryEntity(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      description: _emptyToNull(_descriptionController.text),
      parentId: _parentId,
      imageUrl: _emptyToNull(_imageUrlController.text),
      displayOrder: int.tryParse(_displayOrderController.text.trim()),
      isActive: _isActive,
      isCustomizable: _isCustomizable,
    );

    final cubit = context.read<CategoryCubit>();
    final error = widget.isEditing
        ? await cubit.update(widget.category!.id!, draft)
        : await cubit.create(draft);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error == null) {
      _showSnack(
        widget.isEditing
            ? AppStrings.adminCategoryUpdated
            : AppStrings.adminCategoryCreated,
      );
      Navigator.of(context).pop();
    } else {
      _showSnack(error, isError: true);
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnackBar.show(
      context,
      message: message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CategoryFormAppBar(isEditing: widget.isEditing),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingMd,
            AppSizes.paddingMd,
            AppSizes.paddingMd,
            AppSizes.fontDisplay,
          ),
          children: [
            CategoryFormFields(
              nameController: _nameController,
              descriptionController: _descriptionController,
              imageUrlController: _imageUrlController,
              displayOrderController: _displayOrderController,
              parentOptions: _parentOptions,
              parentId: _parentId,
              isActive: _isActive,
              isCustomizable: _isCustomizable,
              onParentChanged: (value) => setState(() => _parentId = value),
              onActiveChanged: (value) => setState(() => _isActive = value),
              onCustomizableChanged: (value) {
                setState(() => _isCustomizable = value);
              },
            ),
            AppSizes.spacingLg,
            CategorySubmitButton(
              isEditing: widget.isEditing,
              isSubmitting: _submitting,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
