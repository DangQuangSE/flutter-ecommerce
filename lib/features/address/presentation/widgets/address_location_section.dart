import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/app_section_card.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_form_helpers.dart';
import 'package:flutter_ecommerce/features/location/domain/entities/location_entity.dart';
import 'package:flutter_ecommerce/features/location/presentation/cubit/location_cubit.dart';
import 'package:flutter_ecommerce/features/location/presentation/cubit/location_state.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressLocationSection extends StatelessWidget {
  final TextEditingController addressLineCtrl;

  const AddressLocationSection({super.key, required this.addressLineCtrl});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: AppStrings.addressShippingSectionTitle,
      icon: Icons.location_on_outlined,
      children: [
        AddressFieldLabel(
          label: AppStrings.addressLineLabel,
          child: AddressTextField(
            controller: addressLineCtrl,
            hint: AppStrings.addressLineHint,
            icon: Icons.home_outlined,
            validator: (v) => v == null || v.trim().isEmpty
                ? AppStrings.addressLineRequired
                : null,
          ),
        ),
        SizedBox(height: AppSizes.fontLg),
        AddressFieldLabel(
          label: AppStrings.addressProvinceLabel,
          child: _LocationDropdown<LocationEntity>(
            hint: AppStrings.addressProvincePickerHint,
            icon: Icons.map_outlined,
            items: (s) => s.provinces,
            selectedItem: (s) => s.selectedProvince,
            isLoading: (_) => false,
            onChanged: (v) {
              if (v != null) context.read<LocationCubit>().selectProvince(v);
            },
            validator: (v) =>
                v == null ? AppStrings.addressProvincePickerRequired : null,
          ),
        ),
        SizedBox(height: AppSizes.fontLg),
        AddressFieldLabel(
          label: AppStrings.addressDistrictLabel,
          child: _LocationDropdown<LocationEntity>(
            hint: AppStrings.addressDistrictPickerHint,
            icon: Icons.location_city_outlined,
            items: (s) => s.districts,
            selectedItem: (s) => s.selectedDistrict,
            isLoading: (s) => s.isLoadingDistricts,
            onChanged: (v) {
              if (v != null) context.read<LocationCubit>().selectDistrict(v);
            },
            validator: (v) =>
                v == null ? AppStrings.addressDistrictPickerRequired : null,
          ),
        ),
        SizedBox(height: AppSizes.fontLg),
        AddressFieldLabel(
          label: AppStrings.addressWardLabel,
          child: _LocationDropdown<LocationEntity>(
            hint: AppStrings.addressWardPickerHint,
            icon: Icons.place_outlined,
            items: (s) => s.wards,
            selectedItem: (s) => s.selectedWard,
            isLoading: (s) => s.isLoadingWards,
            onChanged: (v) {
              if (v != null) context.read<LocationCubit>().selectWard(v);
            },
            validator: (v) =>
                v == null ? AppStrings.addressWardPickerRequired : null,
          ),
        ),
      ],
    );
  }
}

class _LocationDropdown<T extends LocationEntity> extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final List<T> Function(LocationLoaded state) items;
  final T? Function(LocationLoaded state) selectedItem;
  final bool Function(LocationLoaded state) isLoading;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const _LocationDropdown({
    required this.hint,
    this.icon,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final loaded = state is LocationLoaded ? state : null;
        final loading = loaded == null || isLoading(loaded);
        return DropdownButtonFormField<T>(
          key: ValueKey(
              'loc_${hint}_${loaded == null ? null : selectedItem(loaded)?.code}'),
          initialValue: loaded == null ? null : selectedItem(loaded),
          menuMaxHeight: 280,
          isExpanded: true,
          style: GoogleFonts.inter(
              fontSize: 14, color: theme.colorScheme.onSurface),
          icon: loading
              ? const AppLoadingView(size: AppSizes.iconSm)
              : Icon(Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: icon != null
                ? Icon(icon,
                    size: 18, color: theme.colorScheme.onSurfaceVariant)
                : null,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: addressInputBorder(theme.dividerColor),
            enabledBorder: addressInputBorder(theme.dividerColor),
            focusedBorder: addressInputBorder(AppColors.primary, 1.6),
            errorBorder: addressInputBorder(Colors.red, 1.2),
            focusedErrorBorder: addressInputBorder(Colors.red, 1.6),
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
