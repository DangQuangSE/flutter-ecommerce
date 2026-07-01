import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';

class BrandFormSheet extends StatefulWidget {
  final BrandEntity? brand;
  final ValueChanged<BrandEntity> onSubmit;

  const BrandFormSheet({
    super.key,
    this.brand,
    required this.onSubmit,
  });

  @override
  State<BrandFormSheet> createState() => _BrandFormSheetState();
}

class _BrandFormSheetState extends State<BrandFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _logoController;
  late final TextEditingController _countryController;
  late final TextEditingController _webController;
  late bool _isActive;

  bool get _isEditing => widget.brand != null;

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    _nameController = TextEditingController(text: brand?.name ?? '');
    _descController = TextEditingController(text: brand?.description ?? '');
    _logoController = TextEditingController(text: brand?.logoUrl ?? '');
    _countryController = TextEditingController(text: brand?.country ?? '');
    _webController = TextEditingController(text: brand?.websiteUrl ?? '');
    _isActive = brand?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _logoController.dispose();
    _countryController.dispose();
    _webController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.length < 2 || name.length > 100) {
      AppSnackBar.show(
        context,
        message: AppStrings.adminBrandNameInvalid,
        type: AppSnackBarType.error,
      );
      return;
    }

    widget.onSubmit(
      BrandEntity(
        id: widget.brand?.id,
        name: name,
        slug: widget.brand?.slug ?? '',
        description: _descController.text.trim(),
        logoUrl: _logoController.text.trim(),
        country: _countryController.text.trim(),
        websiteUrl: _webController.text.trim(),
        isActive: _isActive,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.paddingLg,
        right: AppSizes.paddingLg,
        top: AppSizes.paddingXl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingXl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHeader(
              isEditing: _isEditing,
              onClose: () => Navigator.pop(context),
            ),
            const Divider(),
            const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
            const _FieldLabel(AppStrings.adminBrandNameLabel),
            _BrandTextField(
              controller: _nameController,
              hintText: AppStrings.adminBrandNameHint,
            ),
            AppSizes.spacingMd,
            const _FieldLabel(AppStrings.adminBrandCountryLabel),
            _BrandTextField(
              controller: _countryController,
              hintText: AppStrings.adminBrandCountryHint,
            ),
            AppSizes.spacingMd,
            const _FieldLabel(AppStrings.adminBrandWebsiteLabel),
            _BrandTextField(
              controller: _webController,
              hintText: AppStrings.adminBrandWebsiteHint,
            ),
            AppSizes.spacingMd,
            const _FieldLabel(AppStrings.adminBrandLogoLabel),
            _BrandTextField(
              controller: _logoController,
              hintText: AppStrings.adminBrandLogoHint,
            ),
            AppSizes.spacingMd,
            const _FieldLabel(AppStrings.adminBrandDescriptionLabel),
            _BrandTextField(
              controller: _descController,
              hintText: AppStrings.adminBrandDescriptionHint,
              maxLines: 3,
            ),
            AppSizes.spacingMd,
            _ActiveSwitch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            AppSizes.spacingLg,
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingLg - 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                elevation: 1,
              ),
              child: Text(
                _isEditing
                    ? AppStrings.adminBrandSaveChanges
                    : AppStrings.adminBrandCreateAction,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.forgotPasswordFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.isEditing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing
              ? AppStrings.adminBrandFormEditTitle
              : AppStrings.adminBrandFormCreateTitle,
          style: GoogleFonts.lexend(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingXs + 2),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontSm - 1,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BrandTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _BrandTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: maxLines > 1
            ? const EdgeInsets.all(AppSizes.paddingSm + AppSizes.paddingXs)
            : const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm + AppSizes.paddingXs,
                vertical: AppSizes.paddingSm + 2,
              ),
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ActiveSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _FieldLabel(AppStrings.adminBrandActiveStatusLabel),
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
