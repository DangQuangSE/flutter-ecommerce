import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(title: Text(title)),
      body: BlocProvider.value(
        value: _locationCubit,
        child: BlocConsumer<AddressCubit, AddressState>(
          listener: (context, state) {
            if (state is AddressLoaded && state.message != null && !state.isSubmitting) {
              context.pop();
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _fullNameCtrl,
                      label: 'Họ và tên *',
                      hint: AppStrings.addressFullNameHint,
                      icon: Icons.person_outline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? AppStrings.addressFullNameRequired
                          : null,
                    ),
                    _buildTextField(
                      controller: _phoneCtrl,
                      label: 'Số điện thoại *',
                      hint: AppStrings.addressPhoneHint,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? AppStrings.addressPhoneRequired
                          : null,
                    ),
                    _buildTextField(
                      controller: _addressLineCtrl,
                      label: 'Địa chỉ cụ thể *',
                      hint: AppStrings.addressLineHint,
                      icon: Icons.home_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? AppStrings.addressLineRequired
                          : null,
                    ),
                    _buildLocationDropdown<LocationModel>(
                      label: 'Tỉnh/Thành phố *',
                      icon: Icons.map_outlined,
                      items: (s) => s.provinces,
                      selectedItem: (s) => s.selectedProvince,
                      isLoading: (_) => false,
                      onChanged: (v) {
                        if (v != null) context.read<LocationCubit>().selectProvince(v);
                      },
                      validator: (v) => v == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
                    ),
                    _buildLocationDropdown<LocationModel>(
                      label: 'Quận/Huyện *',
                      icon: Icons.location_city_outlined,
                      items: (s) => s.districts,
                      selectedItem: (s) => s.selectedDistrict,
                      isLoading: (s) => s.isLoadingDistricts,
                      onChanged: (v) {
                        if (v != null) context.read<LocationCubit>().selectDistrict(v);
                      },
                      validator: (v) => v == null ? 'Vui lòng chọn quận/huyện' : null,
                    ),
                    _buildLocationDropdown<LocationModel>(
                      label: 'Phường/Xã *',
                      icon: Icons.place_outlined,
                      items: (s) => s.wards,
                      selectedItem: (s) => s.selectedWard,
                      isLoading: (s) => s.isLoadingWards,
                      onChanged: (v) {
                        if (v != null) context.read<LocationCubit>().selectWard(v);
                      },
                      validator: (v) => v == null ? 'Vui lòng chọn phường/xã' : null,
                    ),
                    _buildTextField(
                      controller: _labelCtrl,
                      label: 'Nhãn địa chỉ',
                      hint: AppStrings.addressLabelHint,
                      icon: Icons.label_outline,
                      required: false,
                    ),
                    const SizedBox(height: AppSizes.paddingSm),
                    CheckboxListTile(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v ?? false),
                      title: const Text(AppStrings.addressIsDefaultHint),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: AppSizes.paddingXl),
                    ElevatedButton(
                      onPressed: state is AddressLoaded && state.isSubmitting
                          ? null
                          : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(AppSizes.buttonMinHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is AddressLoaded && state.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? AppStrings.addressUpdate
                                  : AppStrings.addressSave,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMd),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: AppSizes.paddingMd,
          ),
        ),
        validator: required ? validator : null,
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
    required String label,
    IconData? icon,
    required List<T> Function(LocationLoaded state) items,
    required T? Function(LocationLoaded state) selectedItem,
    required bool Function(LocationLoaded state) isLoading,
    required void Function(T?) onChanged,
    required String? Function(T?)? validator,
  }) {
    OutlineInputBorder borderOf(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final loaded = state is LocationLoaded ? state : null;
        final loading = loaded == null || isLoading(loaded);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingMd),
          child: DropdownButtonFormField<T>(
            key: ValueKey('loc_${label}_${loaded == null ? null : selectedItem(loaded)?.code}'),
            value: loaded == null ? null : selectedItem(loaded),
            menuMaxHeight: 280,
            isExpanded: true,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              filled: true,
              fillColor: AppColors.white,
              border: borderOf(const Color(0xFFE5E7EB)),
              enabledBorder: borderOf(const Color(0xFFE5E7EB)),
              focusedBorder: borderOf(AppColors.primary, 1.6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingMd,
              ),
            ),
            items: loaded == null
                ? const []
                : items(loaded)
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
            onChanged: loading ? null : onChanged,
            validator: validator,
          ),
        );
      },
    );
  }
}
