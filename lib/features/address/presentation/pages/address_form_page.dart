import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_contact_section.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_location_section.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_options_section.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_submit_bar.dart';
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
    Future.microtask(() {
      if (!mounted) return;
      final locationCubit = context.read<LocationCubit>();
      if (_isEditing) {
        locationCubit.initializeFromNames(a?.city, a?.district, a?.ward);
      } else {
        locationCubit.loadProvinces();
      }
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressLineCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(
          _isEditing
              ? AppStrings.addressFormEditTitle
              : AppStrings.addressFormTitle,
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      bottomNavigationBar:
          AddressSubmitBar(isEditing: _isEditing, onSubmit: _handleSubmit),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressLoaded &&
              state.message != null &&
              !state.isSubmitting) {
            context.pop();
          }
        },
        builder: (context, state) => Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingMd,
              AppSizes.paddingMd,
              AppSizes.paddingMd,
              AppSizes.fontDisplay,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AddressContactSection(
                  fullNameCtrl: _fullNameCtrl,
                  phoneCtrl: _phoneCtrl,
                ),
                SizedBox(height: AppSizes.radiusLg),
                AddressLocationSection(addressLineCtrl: _addressLineCtrl),
                SizedBox(height: AppSizes.radiusLg),
                AddressOptionsSection(
                  labelCtrl: _labelCtrl,
                  isDefault: _isDefault,
                  onToggleDefault: () =>
                      setState(() => _isDefault = !_isDefault),
                ),
                SizedBox(height: AppSizes.paddingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final locState = context.read<LocationCubit>().state;
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
}
