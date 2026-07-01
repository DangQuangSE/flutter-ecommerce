import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_state.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_cover_picker.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_error_view.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_logo_picker.dart';

class AdminShopConfigPage extends StatelessWidget {
  const AdminShopConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.adminShopConfigTitle,
          style: GoogleFonts.lexend(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.fontXl,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: BlocBuilder<ShopCubit, ShopState>(
          builder: (context, state) => switch (state) {
            ShopInitial() || ShopLoading() => const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ShopLoaded(:final shop) => _AdminShopForm(initialShop: shop),
            ShopError(:final message) => ShopErrorView(
                message: message,
                onRetry: () => context.read<ShopCubit>().loadShop(),
              ),
          },
        ),
      ),
    );
  }
}

class _AdminShopForm extends StatefulWidget {
  final ShopEntity initialShop;

  const _AdminShopForm({required this.initialShop});

  @override
  State<_AdminShopForm> createState() => _AdminShopFormState();
}

class _AdminShopFormState extends State<_AdminShopForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _isUploadingCover = false;

  late String? _logoUrl;
  late String? _coverUrl;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _openingHoursCtrl;
  late final TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.initialShop;
    _logoUrl = s.logoUrl;
    _coverUrl = s.coverUrl;
    _nameCtrl = TextEditingController(text: s.name);
    _addressCtrl = TextEditingController(text: s.address ?? '');
    _phoneCtrl = TextEditingController(text: s.phone ?? '');
    _openingHoursCtrl = TextEditingController(text: s.openingHours ?? '');
    _descriptionCtrl = TextEditingController(text: s.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _openingHoursCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderPicker(context),
            const SizedBox(height: AppSizes.shopLogoSize / 2 + AppSizes.paddingMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildField(
                    controller: _nameCtrl,
                    label: AppStrings.shopFieldName,
                    hint: AppStrings.shopFieldNameHint,
                    validator: _validateRequired,
                  ),
                  AppSizes.spacingMd,
                  _buildField(
                    controller: _addressCtrl,
                    label: AppStrings.shopFieldAddress,
                    hint: AppStrings.shopFieldAddressHint,
                  ),
                  AppSizes.spacingMd,
                  _buildField(
                    controller: _phoneCtrl,
                    label: AppStrings.shopFieldPhone,
                    hint: AppStrings.shopFieldPhoneHint,
                    keyboardType: TextInputType.phone,
                  ),
                  AppSizes.spacingMd,
                  _buildField(
                    controller: _openingHoursCtrl,
                    label: AppStrings.shopFieldOpeningHours,
                    hint: AppStrings.shopFieldOpeningHoursHint,
                  ),
                  AppSizes.spacingMd,
                  _buildField(
                    controller: _descriptionCtrl,
                    label: AppStrings.shopFieldDescription,
                    hint: AppStrings.shopFieldDescriptionHint,
                    maxLines: 4,
                  ),
                  AppSizes.spacingLg,
                  _SubmitButton(
                    isSaving: _isSaving,
                    onPressed: _submit,
                  ),
                  AppSizes.spacingLg,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPicker(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final coverHeight = constraints.maxWidth * AppSizes.shopCoverRatio;
      return SizedBox(
        height: coverHeight + AppSizes.shopLogoSize / 2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: coverHeight,
              child: ShopCoverPicker(
                imageUrl: _coverUrl,
                isUploading: _isUploadingCover,
                onTap: () => _pickAndUpload('cover'),
              ),
            ),
            Positioned(
              bottom: 0,
              left: AppSizes.paddingMd,
              child: ShopLogoPicker(
                imageUrl: _logoUrl,
                shopName: _nameCtrl.text,
                isUploading: _isUploadingLogo,
                onTap: () => _pickAndUpload('logo'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _pickAndUpload(String type) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (type == 'logo') {
        _isUploadingLogo = true;
      } else {
        _isUploadingCover = true;
      }
    });

    final cubit = context.read<ShopCubit>();
    final (:url, :error) =
        await cubit.uploadShopImageWithUrl(File(picked.path), type);

    if (!mounted) return;
    setState(() {
      if (type == 'logo') {
        _isUploadingLogo = false;
        if (url != null) _logoUrl = url;
      } else {
        _isUploadingCover = false;
        if (url != null) _coverUrl = url;
      }
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.shopImageUploadError),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: AppSizes.fontLg,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.shopValidationNameRequired;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final draft = widget.initialShop.copyWith(
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      openingHours: _openingHoursCtrl.text.trim().isEmpty
          ? null
          : _openingHoursCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      logoUrl: _logoUrl,
      coverUrl: _coverUrl,
    );

    final cubit = context.read<ShopCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await cubit.updateShop(draft);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(AppStrings.shopUpdateSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isSaving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(AppSizes.buttonMinHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
      ),
      child: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              AppStrings.shopSaveChanges,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.fontXl,
              ),
            ),
    );
  }
}
