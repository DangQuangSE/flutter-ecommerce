import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';

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
  late final TextEditingController _wardCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _labelCtrl;
  bool _isDefault = false;
  bool get _isEditing => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    _fullNameCtrl = TextEditingController(text: a?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: a?.phoneNumber ?? '');
    _addressLineCtrl = TextEditingController(text: a?.addressLine ?? '');
    _wardCtrl = TextEditingController(text: a?.ward ?? '');
    _districtCtrl = TextEditingController(text: a?.district ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _labelCtrl = TextEditingController(text: a?.label ?? '');
    _isDefault = a?.isDefault ?? false;
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

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? AppStrings.addressFormEditTitle : AppStrings.addressFormTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocConsumer<AddressCubit, AddressState>(
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
                    hint: AppStrings.addressFullNameHint,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? AppStrings.addressFullNameRequired
                        : null,
                  ),
                  _buildTextField(
                    controller: _phoneCtrl,
                    hint: AppStrings.addressPhoneHint,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? AppStrings.addressPhoneRequired
                        : null,
                  ),
                  _buildTextField(
                    controller: _addressLineCtrl,
                    hint: AppStrings.addressLineHint,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? AppStrings.addressLineRequired
                        : null,
                  ),
                  _buildTextField(
                    controller: _wardCtrl,
                    hint: AppStrings.addressWardHint,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? AppStrings.addressWardRequired
                        : null,
                  ),
                  _buildTextField(
                    controller: _districtCtrl,
                    hint: AppStrings.addressDistrictHint,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? AppStrings.addressDistrictRequired
                        : null,
                  ),
                  _buildTextField(
                    controller: _cityCtrl,
                    hint: AppStrings.addressCityHint,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? AppStrings.addressCityRequired
                        : null,
                  ),
                  _buildTextField(
                    controller: _labelCtrl,
                    hint: AppStrings.addressLabelHint,
                    required: false,
                  ),
                  const SizedBox(height: AppSizes.paddingSm),
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v ?? false),
                    title: const Text(AppStrings.addressIsDefaultHint),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: AppSizes.paddingXl),
                  ElevatedButton(
                    onPressed: state is AddressLoaded && state.isSubmitting
                        ? null
                        : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(AppSizes.buttonMinHeight),
                    ),
                    child: Text(
                      _isEditing ? AppStrings.addressUpdate : AppStrings.addressSave,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
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
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: AppSizes.paddingSm,
          ),
        ),
        validator: required
            ? validator
            : null,
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final entity = AddressEntity(
      id: widget.initialAddress?.id,
      fullName: _fullNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      addressLine: _addressLineCtrl.text.trim(),
      ward: _wardCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
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
}
