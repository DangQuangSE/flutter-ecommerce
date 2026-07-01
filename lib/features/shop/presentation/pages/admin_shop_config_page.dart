import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_state.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_error_view.dart';

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
            ShopInitial() => Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ShopLoading() => Center(
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
  bool _isSaving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _ratingCountCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _openingHoursCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _logoUrlCtrl;
  late final TextEditingController _coverUrlCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.initialShop;
    _nameCtrl = TextEditingController(text: s.name);
    _addressCtrl = TextEditingController(text: s.address ?? '');
    _ratingCtrl = TextEditingController(
      text: s.rating != null ? s.rating!.toString() : '',
    );
    _ratingCountCtrl =
        TextEditingController(text: s.ratingCount.toString());
    _phoneCtrl = TextEditingController(text: s.phone ?? '');
    _openingHoursCtrl =
        TextEditingController(text: s.openingHours ?? '');
    _descriptionCtrl =
        TextEditingController(text: s.description ?? '');
    _logoUrlCtrl = TextEditingController(text: s.logoUrl ?? '');
    _coverUrlCtrl = TextEditingController(text: s.coverUrl ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _ratingCtrl.dispose();
    _ratingCountCtrl.dispose();
    _phoneCtrl.dispose();
    _openingHoursCtrl.dispose();
    _descriptionCtrl.dispose();
    _logoUrlCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: AppSizes.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormChildren(context),
        ),
      ),
    );
  }

  List<Widget> _buildFormChildren(BuildContext context) {
    return [
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
        controller: _ratingCtrl,
        label: AppStrings.shopFieldRating,
        hint: AppStrings.shopFieldRatingHint,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: _validateRating,
      ),
      AppSizes.spacingMd,
      _buildField(
        controller: _ratingCountCtrl,
        label: AppStrings.shopFieldRatingCount,
        hint: AppStrings.shopFieldRatingCountHint,
        keyboardType: TextInputType.number,
        validator: _validateRatingCount,
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
      AppSizes.spacingMd,
      _buildField(
        controller: _logoUrlCtrl,
        label: AppStrings.shopFieldLogoUrl,
        hint: AppStrings.shopFieldLogoUrlHint,
        keyboardType: TextInputType.url,
      ),
      AppSizes.spacingMd,
      _buildField(
        controller: _coverUrlCtrl,
        label: AppStrings.shopFieldCoverUrl,
        hint: AppStrings.shopFieldCoverUrlHint,
        keyboardType: TextInputType.url,
      ),
      AppSizes.spacingLg,
      _SubmitButton(isSaving: _isSaving, onPressed: () => _submit(context)),
      AppSizes.spacingLg,
    ];
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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
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

  String? _validateRating(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return AppStrings.shopValidationRatingInvalid;
    if (parsed < 0 || parsed > 5) {
      return AppStrings.shopValidationRatingRange;
    }
    return null;
  }

  String? _validateRatingCount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return AppStrings.shopValidationRatingCountInvalid;
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final ratingText = _ratingCtrl.text.trim();
    final ratingCountText = _ratingCountCtrl.text.trim();

    final draft = widget.initialShop.copyWith(
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      rating:
          ratingText.isEmpty ? null : double.tryParse(ratingText),
      ratingCount: ratingCountText.isEmpty
          ? 0
          : int.tryParse(ratingCountText) ?? 0,
      phone: _phoneCtrl.text.trim().isEmpty
          ? null
          : _phoneCtrl.text.trim(),
      openingHours: _openingHoursCtrl.text.trim().isEmpty
          ? null
          : _openingHoursCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      logoUrl: _logoUrlCtrl.text.trim().isEmpty
          ? null
          : _logoUrlCtrl.text.trim(),
      coverUrl: _coverUrlCtrl.text.trim().isEmpty
          ? null
          : _coverUrlCtrl.text.trim(),
    );

    // Capture context-dependent objects before the async gap.
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
          ? SizedBox(
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