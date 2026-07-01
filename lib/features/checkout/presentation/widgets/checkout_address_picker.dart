import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';

class CheckoutAddressPicker extends StatelessWidget {
  final AddressEntity? selectedAddress;
  final ValueChanged<AddressEntity> onAddressSelected;

  const CheckoutAddressPicker({
    super.key,
    required this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        return switch (state) {
          AddressInitial() || AddressLoading() => _buildLoadingCard(context),
          AddressLoaded(:final addresses) => addresses.isEmpty
              ? _buildNoAddressCard(context)
              : _buildAddressCard(context, addresses),
          AddressError() => _buildNoAddressCard(context),
        };
      },
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
      ),
      child: const AppLoadingView(size: AppSizes.iconMd),
    );
  }

  Widget _buildNoAddressCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_off_outlined,
                size: AppSizes.fontXxl,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AppSizes.paddingSm),
              Text(
                AppStrings.checkoutNoAddressTitle,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.radiusLg),
          Text(
            AppStrings.checkoutNoAddressMessage,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMd,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.radiusLg),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed(AppRoutes.addressForm),
            icon: Icon(Icons.add, size: AppSizes.iconSm),
            label: Text(
              AppStrings.checkoutAddAddress,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.radiusMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.paddingSm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
      BuildContext context, List<AddressEntity> addresses) {
    final theme = Theme.of(context);
    final displayAddress = selectedAddress ?? _findDefaultOrFirst(addresses);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.radiusSm),
              Text(
                displayAddress.fullName,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.forgotPasswordFontSize,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (displayAddress.isDefault)
                Padding(
                  padding: const EdgeInsets.only(left: AppSizes.paddingSm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.radiusSm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.paddingXs),
                    ),
                    child: Text(
                      AppStrings.checkoutDefaultAddress,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontBadge,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openAddressPicker(context, addresses),
                child: Text(
                  AppStrings.checkoutChangeAddress,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSm - 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingSm),
          Text(
            displayAddress.phoneNumber,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.paddingXs),
          Text(
            displayAddress.formattedAddress,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMd,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (displayAddress.label != null &&
              displayAddress.label!.isNotEmpty) ...[
            SizedBox(height: AppSizes.radiusSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.radiusSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.paddingXs),
              ),
              child: Text(
                displayAddress.label!,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  AddressEntity _findDefaultOrFirst(List<AddressEntity> addresses) {
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.first;
  }

  void _openAddressPicker(BuildContext context, List<AddressEntity> addresses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusRound),
        ),
      ),
      builder: (modalContext) => _AddressPickerSheet(
        addresses: addresses,
        selectedAddress: selectedAddress,
        onAddressSelected: (addr) {
          onAddressSelected(addr);
          Navigator.pop(modalContext);
        },
      ),
    );
  }
}

class _AddressPickerSheet extends StatelessWidget {
  final List<AddressEntity> addresses;
  final AddressEntity? selectedAddress;
  final ValueChanged<AddressEntity> onAddressSelected;

  const _AddressPickerSheet({
    required this.addresses,
    this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: AppSizes.paddingXs,
              decoration: BoxDecoration(
                color: const Color(0xFFC1C6D7).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: AppSizes.paddingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.checkoutSelectAddressTitle,
                  style: GoogleFonts.lexend(
                    fontSize: AppSizes.submitButtonFontSize,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: AppSizes.iconMd),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSizes.radiusLg),
              itemBuilder: (_, index) {
                final addr = addresses[index];
                final isSelected = addr.id == selectedAddress?.id;
                return _AddressPickerTile(
                  address: addr,
                  isSelected: isSelected,
                  onTap: () => onAddressSelected(addr),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.pushNamed(AppRoutes.addressForm);
                },
                icon: Icon(Icons.add, size: AppSizes.iconSm),
                label: Text(
                  AppStrings.checkoutAddNewAddress,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.radiusLg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.paddingSm),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressPickerTile extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressPickerTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.fontLg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFC1C6D7).withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.fullName,
                        style: GoogleFonts.lexend(
                          fontSize: AppSizes.forgotPasswordFontSize,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (address.isDefault)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: AppSizes.radiusSm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingXs + 1,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              AppStrings.checkoutDefaultAddress,
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.fontXxs,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingXs),
                  Text(
                    address.phoneNumber,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    address.formattedAddress,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSm,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.paddingSm),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  size: AppSizes.iconMd, color: AppColors.primary)
            else
              Icon(Icons.radio_button_unchecked_rounded,
                  size: AppSizes.iconMd, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
