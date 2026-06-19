import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_ecommerce/features/location/data/models/location_model.dart';
import 'package:flutter_ecommerce/features/location/presentation/cubit/location_cubit.dart';
import 'package:flutter_ecommerce/features/location/presentation/cubit/location_state.dart';

class AddressFormPage extends StatefulWidget {
  final AddressEntity? initialAddress;

  const AddressFormPage({super.key, this.initialAddress});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressLineCtrl;
  late final TextEditingController _labelCtrl;
  late final LocationCubit _locationCubit;
  bool _isDefault = false;
  bool get _isEditing => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    _fullNameCtrl = TextEditingController(text: a?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: a?.phoneNumber ?? '');
    _addressLineCtrl = TextEditingController(text: a?.addressLine ?? '');
    _labelCtrl = TextEditingController(text: a?.label ?? '');
    _isDefault = a?.isDefault ?? false;
    _locationCubit = sl<LocationCubit>();
    if (_isEditing) {
      _locationCubit.initializeFromNames(a?.city, a?.district, a?.ward);
    } else {
      _locationCubit.loadProvinces();
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressLineCtrl.dispose();
    _labelCtrl.dispose();
    _locationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? AppStrings.addressFormEditTitle : AppStrings.addressFormTitle;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      bottomNavigationBar: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          final isSubmitting = state is AddressLoaded && state.isSubmitting;
          return Container(
            padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: SizedBox(
              height: AppSizes.buttonMinHeight,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Text(
                        _isEditing ? AppStrings.addressUpdate : AppStrings.addressSave,
                        style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
      body: BlocProvider.value(
        value: _locationCubit,
        child: BlocConsumer<AddressCubit, AddressState>(
          listener: (context, state) {
            if (state is AddressLoaded && state.message != null && !state.isSubmitting) {
              context.pop();
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Contact info
                    _buildSectionCard(
                      title: 'Thông tin người nhận',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _buildLabeledField(
                          label: 'Họ và tên',
                          required: true,
                          child: _buildTextFormField(
                            controller: _fullNameCtrl,
                            hint: AppStrings.addressFullNameHint,
                            icon: Icons.person_outline,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? AppStrings.addressFullNameRequired
                                : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildLabeledField(
                          label: 'Số điện thoại',
                          required: true,
                          child: _buildTextFormField(
                            controller: _phoneCtrl,
                            hint: AppStrings.addressPhoneHint,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return AppStrings.addressPhoneRequired;
                              }
                              final phone = v.trim();
                              if (!RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$').hasMatch(phone)) {
                                return 'Số điện thoại không hợp lệ (VD: 0912345678)';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Section 2: Address detail
                    _buildSectionCard(
                      title: 'Địa chỉ giao hàng',
                      icon: Icons.location_on_outlined,
                      children: [
                        _buildLabeledField(
                          label: 'Số nhà, tên đường',
                          required: true,
                          child: _buildTextFormField(
                            controller: _addressLineCtrl,
                            hint: AppStrings.addressLineHint,
                            icon: Icons.home_outlined,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? AppStrings.addressLineRequired
                                : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildLabeledField(
                          label: 'Tỉnh / Thành phố',
                          required: true,
                          child: _buildLocationDropdown<LocationModel>(
                            hint: 'Chọn tỉnh/thành phố',
                            icon: Icons.map_outlined,
                            items: (s) => s.provinces,
                            selectedItem: (s) => s.selectedProvince,
                            isLoading: (_) => false,
                            onChanged: (v) {
                              if (v != null) context.read<LocationCubit>().selectProvince(v);
                            },
                            validator: (v) =>
                                v == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildLabeledField(
                          label: 'Quận / Huyện',
                          required: true,
                          child: _buildLocationDropdown<LocationModel>(
                            hint: 'Chọn quận/huyện',
                            icon: Icons.location_city_outlined,
                            items: (s) => s.districts,
                            selectedItem: (s) => s.selectedDistrict,
                            isLoading: (s) => s.isLoadingDistricts,
                            onChanged: (v) {
                              if (v != null) context.read<LocationCubit>().selectDistrict(v);
                            },
                            validator: (v) =>
                                v == null ? 'Vui lòng chọn quận/huyện' : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildLabeledField(
                          label: 'Phường / Xã',
                          required: true,
                          child: _buildLocationDropdown<LocationModel>(
                            hint: 'Chọn phường/xã',
                            icon: Icons.place_outlined,
                            items: (s) => s.wards,
                            selectedItem: (s) => s.selectedWard,
                            isLoading: (s) => s.isLoadingWards,
                            onChanged: (v) {
                              if (v != null) context.read<LocationCubit>().selectWard(v);
                            },
                            validator: (v) =>
                                v == null ? 'Vui lòng chọn phường/xã' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Section 3: Optional
                    _buildSectionCard(
                      title: 'Tuỳ chọn',
                      icon: Icons.tune_outlined,
                      children: [
                        _buildLabeledField(
                          label: 'Nhãn địa chỉ',
                          required: false,
                          hint: 'Ví dụ: Nhà, Công ty...',
                          child: _buildTextFormField(
                            controller: _labelCtrl,
                            hint: AppStrings.addressLabelHint,
                            icon: Icons.label_outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDefaultToggle(),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
    bool required = true,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            if (!required && hint != null) ...[
              const SizedBox(width: 6),
              Text(
                hint,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textHint),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: AppColors.textSecondary)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.6),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDefaultToggle() {
    return InkWell(
      onTap: () => setState(() => _isDefault = !_isDefault),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isDefault
              ? AppColors.primary.withValues(alpha: 0.06)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isDefault ? AppColors.primary : const Color(0xFFE5E7EB),
            width: _isDefault ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 18,
              color: _isDefault ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.addressIsDefaultHint,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isDefault ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Dùng địa chỉ này mặc định khi đặt hàng',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _isDefault ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isDefault ? AppColors.primary : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: _isDefault
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final locState = _locationCubit.state;
    String city = '', district = '', ward = '';
    if (locState is LocationLoaded) {
      city = locState.selectedProvince?.name ?? '';
      district = locState.selectedDistrict?.name ?? '';
      ward = locState.selectedWard?.name ?? '';
    }

    final entity = AddressEntity(
      id: widget.initialAddress?.id,
      fullName: _fullNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      addressLine: _addressLineCtrl.text.trim(),
      ward: ward,
      district: district,
      city: city,
      label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
      isDefault: _isDefault,
    );

    final cubit = context.read<AddressCubit>();
    if (_isEditing) {
      cubit.updateAddress(widget.initialAddress!.id!, entity);
    } else {
      cubit.createAddress(entity);
    }
  }

  Widget _buildLocationDropdown<T extends LocationModel>({
    required String hint,
    IconData? icon,
    required List<T> Function(LocationLoaded state) items,
    required T? Function(LocationLoaded state) selectedItem,
    required bool Function(LocationLoaded state) isLoading,
    required void Function(T?) onChanged,
    required String? Function(T?)? validator,
  }) {
    OutlineInputBorder borderOf(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final loaded = state is LocationLoaded ? state : null;
        final loading = loaded == null || isLoading(loaded);
        return DropdownButtonFormField<T>(
          key: ValueKey('loc_${hint}_${loaded == null ? null : selectedItem(loaded)?.code}'),
          initialValue: loaded == null ? null : selectedItem(loaded),
          menuMaxHeight: 280,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textHint),
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: AppColors.textSecondary)
                : null,
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: borderOf(const Color(0xFFE5E7EB)),
            enabledBorder: borderOf(const Color(0xFFE5E7EB)),
            focusedBorder: borderOf(AppColors.primary, 1.6),
            errorBorder: borderOf(Colors.red, 1.2),
            focusedErrorBorder: borderOf(Colors.red, 1.6),
          ),
          items: loaded == null
              ? const []
              : items(loaded)
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ))
                  .toList(),
          onChanged: loading ? null : onChanged,
          validator: validator,
        );
      },
    );
  }
}
