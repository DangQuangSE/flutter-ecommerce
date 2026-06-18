import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/address/data/datasources/vietnam_address_service.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key, this.initial});

  final AddressEntity? initial;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressLineCtrl;
  late final TextEditingController _wardCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _labelCtrl;
  late bool _isDefault;

  final _vietnamAddressService = VietnamAddressService();

  List<VietnamProvince> _provinces = [];
  List<VietnamDistrict> _districts = [];
  List<VietnamWard> _wards = [];

  VietnamProvince? _selectedProvince;
  VietnamDistrict? _selectedDistrict;
  VietnamWard? _selectedWard;

  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;
  bool _isLoadingInitialData = false;

  bool _useManualInput = false;

  bool get _isEditing => widget.initial?.id != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _fullNameCtrl = TextEditingController(text: a?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: a?.phoneNumber ?? '');
    _addressLineCtrl = TextEditingController(text: a?.addressLine ?? '');
    _wardCtrl = TextEditingController(text: a?.ward ?? '');
    _districtCtrl = TextEditingController(text: a?.district ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _labelCtrl = TextEditingController(text: a?.label ?? '');
    _isDefault = a?.isDefault ?? false;

    _initAddressData();
  }

  Future<void> _initAddressData() async {
    setState(() {
      _isLoadingInitialData = true;
      _isLoadingProvinces = true;
    });

    try {
      final provinces = await _vietnamAddressService.getProvinces();
      if (!mounted) return;

      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;
      });

      if (_isEditing) {
        final initialCity = widget.initial?.city ?? '';
        final matchedProvince = _findMatchingProvince(initialCity, provinces);

        if (matchedProvince != null) {
          setState(() {
            _selectedProvince = matchedProvince;
            _isLoadingDistricts = true;
          });

          final districts = await _vietnamAddressService.getDistricts(matchedProvince.code);
          if (!mounted) return;

          setState(() {
            _districts = districts;
            _isLoadingDistricts = false;
          });

          final initialDistrict = widget.initial?.district ?? '';
          final matchedDistrict = _findMatchingDistrict(initialDistrict, districts);

          if (matchedDistrict != null) {
            setState(() {
              _selectedDistrict = matchedDistrict;
              _isLoadingWards = true;
            });

            final wards = await _vietnamAddressService.getWards(matchedDistrict.code);
            if (!mounted) return;

            setState(() {
              _wards = wards;
              _isLoadingWards = false;
            });

            final initialWard = widget.initial?.ward ?? '';
            final matchedWard = _findMatchingWard(initialWard, wards);

            if (matchedWard != null) {
              setState(() {
                _selectedWard = matchedWard;
              });
            } else {
              setState(() {
                _useManualInput = true;
              });
            }
          } else {
            setState(() {
              _useManualInput = true;
            });
          }
        } else {
          setState(() {
            _useManualInput = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _useManualInput = true;
          _isLoadingProvinces = false;
          _isLoadingDistricts = false;
          _isLoadingWards = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách tỉnh/thành: $e. Chuyển sang nhập thủ công.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  VietnamProvince? _findMatchingProvince(String query, List<VietnamProvince> list) {
    if (query.isEmpty) return null;
    final q = query.toLowerCase().replaceAll('tp.', 'thành phố').replaceAll(' ', '').trim();
    for (final item in list) {
      final name = item.name.toLowerCase().replaceAll('tp.', 'thành phố').replaceAll(' ', '').trim();
      if (name == q || name.contains(q) || q.contains(name)) {
        return item;
      }
    }
    return null;
  }

  VietnamDistrict? _findMatchingDistrict(String query, List<VietnamDistrict> list) {
    if (query.isEmpty) return null;
    final q = query.toLowerCase().replaceAll(' ', '').trim();
    for (final item in list) {
      final name = item.name.toLowerCase().replaceAll(' ', '').trim();
      if (name == q || name.contains(q) || q.contains(name)) {
        return item;
      }
    }
    return null;
  }

  VietnamWard? _findMatchingWard(String query, List<VietnamWard> list) {
    if (query.isEmpty) return null;
    final q = query.toLowerCase().replaceAll(' ', '').trim();
    for (final item in list) {
      final name = item.name.toLowerCase().replaceAll(' ', '').trim();
      if (name == q || name.contains(q) || q.contains(name)) {
        return item;
      }
    }
    return null;
  }

  Future<void> _onProvinceChanged(VietnamProvince? province) async {
    if (province == null || province == _selectedProvince) return;
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;
      _selectedWard = null;
      _districts = [];
      _wards = [];
      _isLoadingDistricts = true;
    });

    try {
      final districts = await _vietnamAddressService.getDistricts(province.code);
      if (!mounted) return;
      setState(() {
        _districts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDistricts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách quận/huyện: $e')),
        );
      }
    }
  }

  Future<void> _onDistrictChanged(VietnamDistrict? district) async {
    if (district == null || district == _selectedDistrict) return;
    setState(() {
      _selectedDistrict = district;
      _selectedWard = null;
      _wards = [];
      _isLoadingWards = true;
    });

    try {
      final wards = await _vietnamAddressService.getWards(district.code);
      if (!mounted) return;
      setState(() {
        _wards = wards;
        _isLoadingWards = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWards = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách phường/xã: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressLineCtrl.dispose();
    _wardCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String city = '';
    String district = '';
    String ward = '';

    if (_useManualInput) {
      city = _cityCtrl.text.trim();
      district = _districtCtrl.text.trim();
      ward = _wardCtrl.text.trim();
    } else {
      if (_selectedProvince == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn tỉnh / thành phố')),
        );
        return;
      }
      if (_selectedDistrict == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn quận / huyện')),
        );
        return;
      }
      if (_selectedWard == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn phường / xã')),
        );
        return;
      }
      city = _selectedProvince!.name;
      district = _selectedDistrict!.name;
      ward = _selectedWard!.name;
    }

    final entity = AddressEntity(
      id: widget.initial?.id,
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
    final success = _isEditing
        ? await cubit.updateAddress(entity)
        : await cubit.addAddress(entity);

    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: AppSizes.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FormField(
                  controller: _fullNameCtrl,
                  label: 'Họ và tên',
                  hint: 'Nguyễn Văn A',
                  validator: _required,
                ),
                AppSizes.spacingMd,
                _FormField(
                  controller: _phoneCtrl,
                  label: 'Số điện thoại',
                  hint: '0987654321',
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                AppSizes.spacingMd,
                _FormField(
                  controller: _addressLineCtrl,
                  label: 'Địa chỉ (số nhà, đường)',
                  hint: '123 Lê Lợi',
                  validator: _required,
                ),
                AppSizes.spacingMd,
                if (_useManualInput) ...[
                  _FormField(
                    controller: _cityCtrl,
                    label: 'Tỉnh / Thành phố',
                    hint: 'Ví dụ: TP. Hồ Chí Minh',
                    validator: _required,
                  ),
                  AppSizes.spacingMd,
                  _FormField(
                    controller: _districtCtrl,
                    label: 'Quận / Huyện',
                    hint: 'Ví dụ: Quận 1',
                    validator: _required,
                  ),
                  AppSizes.spacingMd,
                  _FormField(
                    controller: _wardCtrl,
                    label: 'Phường / Xã',
                    hint: 'Ví dụ: Phường Bến Nghé',
                    validator: _required,
                  ),
                ] else ...[
                  _GenericDropdownField<VietnamProvince>(
                    label: 'Tỉnh / Thành phố',
                    hint: 'Chọn tỉnh / thành phố',
                    value: _selectedProvince,
                    items: _provinces,
                    isLoading: _isLoadingProvinces,
                    itemLabel: (p) => p.name,
                    onChanged: _isLoadingInitialData ? null : _onProvinceChanged,
                  ),
                  AppSizes.spacingMd,
                  _GenericDropdownField<VietnamDistrict>(
                    label: 'Quận / Huyện',
                    hint: 'Chọn quận / huyện',
                    value: _selectedDistrict,
                    items: _districts,
                    isLoading: _isLoadingDistricts,
                    itemLabel: (d) => d.name,
                    onChanged: _isLoadingInitialData || _selectedProvince == null
                        ? null
                        : _onDistrictChanged,
                  ),
                  AppSizes.spacingMd,
                  _GenericDropdownField<VietnamWard>(
                    label: 'Phường / Xã',
                    hint: 'Chọn phường / xã',
                    value: _selectedWard,
                    items: _wards,
                    isLoading: _isLoadingWards,
                    itemLabel: (w) => w.name,
                    onChanged: _isLoadingInitialData || _selectedDistrict == null
                        ? null
                        : (w) => setState(() => _selectedWard = w),
                  ),
                ],
                AppSizes.spacingMd,
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    setState(() {
                      _useManualInput = !_useManualInput;
                      if (_useManualInput) {
                        _cityCtrl.text = _selectedProvince?.name ?? _cityCtrl.text;
                        _districtCtrl.text = _selectedDistrict?.name ?? _districtCtrl.text;
                        _wardCtrl.text = _selectedWard?.name ?? _wardCtrl.text;
                      }
                    });
                  },
                  icon: Icon(
                    _useManualInput ? Icons.list_rounded : Icons.edit_note_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  label: Text(
                    _useManualInput ? 'Chọn từ danh sách (Dropdown)' : 'Nhập địa chỉ thủ công',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                AppSizes.spacingMd,
                _FormField(
                  controller: _labelCtrl,
                  label: 'Nhãn (tuỳ chọn)',
                  hint: 'Nhà, Công ty...',
                ),
                AppSizes.spacingMd,
                _DefaultToggle(
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
                AppSizes.spacingLg,
                BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, state) {
                    final loading = state is AddressLoading;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(
                          double.infinity,
                          AppSizes.buttonMinHeight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLg),
                        ),
                      ),
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing ? 'Lưu thay đổi' : 'Thêm địa chỉ',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Vui lòng điền thông tin này' : null;

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng điền thông tin này';
    }
    final cleanPhone = value.trim().replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9,10}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Số điện thoại không hợp lệ (Ví dụ: 0987654321)';
    }
    return null;
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenericDropdownField<T> extends StatelessWidget {
  const _GenericDropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.isLoading,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final bool isLoading;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppSizes.fontLg,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (val) {
            if (val == null) {
              return 'Vui lòng chọn trường này';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _DefaultToggle extends StatelessWidget {
  const _DefaultToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? AppColors.primary : AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
            AppSizes.spacingSm,
            Text(
              'Đặt làm địa chỉ mặc định',
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
