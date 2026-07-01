import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/widgets/address_card.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addressListTitle)),
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
          return switch (state) {
            AddressInitial() || AddressLoading() => const _LoadingState(),
            AddressError(:final message) => _ErrorState(message: message),
            AddressLoaded() => _AddressListView(),
          };
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

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
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconXxl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.paddingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: AppSizes.fontLg),
            ),
            const SizedBox(height: AppSizes.paddingMd),
            ElevatedButton(
              onPressed: () => context.read<AddressCubit>().loadAddresses(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressCubit>().state;
    if (addresses is! AddressLoaded) return const SizedBox.shrink();

    if (addresses.addresses.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => context.read<AddressCubit>().loadAddresses(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            itemCount: addresses.addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses.addresses[index];
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
                onDelete: () {
                  _confirmDelete(context, addr.id!);
                },
              );
            },
          ),
        ),
        if (addresses.isSubmitting)
          const Positioned.fill(
            child: AppLoadingView(),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: AppSizes.paddingMd),
            const Text(
              AppStrings.addressEmptyTitle,
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSm),
            const Text(
              AppStrings.addressEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXl),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(AppRoutes.addressForm),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addressAdd),
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
