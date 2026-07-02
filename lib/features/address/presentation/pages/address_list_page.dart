import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_card.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressLoaded && state.message != null) {
            AppSnackBar.show(
              context,
              message: state.message!,
              type: AppSnackBarType.success,
            );
          }
          if (state is AddressError) {
            AppSnackBar.show(
              context,
              message: state.message,
              type: AppSnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _BodyContent(
                state: state,
                topPadding: statusBarHeight + 90,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _AddressAppBar(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _AddAddressFab(),
    );
  }
}

class _AddressAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.profile);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimaryLight,
              size: AppSizes.iconMd,
            ),
          ),
          Expanded(
            child: Text(
              AppStrings.addressListTitle,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
          ),
          BlocBuilder<AddressCubit, AddressState>(
            builder: (context, state) {
              final count = state is AddressLoaded
                  ? state.addresses.length
                  : 0;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.spaceMono(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final AddressState state;
  final double topPadding;

  const _BodyContent({required this.state, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AddressInitial() || AddressLoading() => _LoadingState(),
      AddressError(:final message) => _ErrorState(message: message),
      AddressLoaded(:final addresses, :final isSubmitting) =>
        _AddressListView(
          addresses: addresses,
          isSubmitting: isSubmitting,
          topPadding: topPadding,
        ),
    };
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AppLoadingView();
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          0,
          AppSizes.paddingXl,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLg),
            _RetryButton(),
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AddressCubit>().loadAddresses(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          AppStrings.retry,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AddressListView extends StatelessWidget {
  final List<AddressEntity> addresses;
  final bool isSubmitting;
  final double topPadding;

  const _AddressListView({
    required this.addresses,
    required this.isSubmitting,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<AddressCubit>().loadAddresses(),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              AppSizes.paddingMd,
              topPadding,
              AppSizes.paddingMd,
              100,
            ),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return AddressCard(
                address: addr,
                onSetDefault: addr.id != null
                    ? () =>
                        context.read<AddressCubit>().setDefaultAddress(addr.id!)
                    : null,
                onEdit: () => context.pushNamed(
                  AppRoutes.addressForm,
                  extra: addr,
                ),
                onDelete: () => _confirmDelete(context, addr.id!),
              );
            },
          ),
        ),
        if (isSubmitting)
          const Positioned.fill(child: AppLoadingView()),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLg),
            Text(
              AppStrings.addressEmptyTitle,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSm),
            Text(
              AppStrings.addressEmptySubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.addressDelete,
      message: AppStrings.addressDeleteConfirm,
      cancelLabel: AppStrings.addressCancel,
      confirmLabel: AppStrings.addressDelete,
    );
    if (confirmed && context.mounted) {
      context.read<AddressCubit>().deleteAddress(id);
    }
  }
}

class _AddAddressFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.addressForm),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          AppStrings.addressAdd,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
