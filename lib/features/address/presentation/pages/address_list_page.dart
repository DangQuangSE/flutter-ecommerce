import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
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
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Colors.green,
                ),
              );
          }
          if (state is AddressError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
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
    return const Center(child: CircularProgressIndicator());
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
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                onDelete: () => _confirmDelete(context, addr.id!),
              );
            },
          ),
        ),
        if (addresses.isSubmitting)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
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

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.addressDelete),
        content: const Text(AppStrings.addressDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.addressCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AddressCubit>().deleteAddress(id);
            },
            child: const Text(AppStrings.addressDelete),
          ),
        ],
      ),
    );
  }
}
