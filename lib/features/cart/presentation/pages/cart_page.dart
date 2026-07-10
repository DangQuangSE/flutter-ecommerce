import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/cart/presentation/utils/cart_item_pricing.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_error_state.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_order_summary.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_sticky_footer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Set<int> _selectedItemIds = {};
  bool _hasInitializedSelection = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      context.read<CartCubit>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            height: 1,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.productList);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: AppSizes.iconMd,
          ),
        ),
        title: Text(
          AppStrings.cartTitle,
          style: GoogleFonts.lexend(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const AppLoadingView();
          } else if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const CartEmptyState();
            }
            return _buildCartContent(context, state);
          } else if (state is CartError) {
            return CartErrorState(
              message: state.message,
              onRetry: () => context.read<CartCubit>().loadCart(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    if (!_hasInitializedSelection) {
      _selectedItemIds.clear();
      _selectedItemIds.addAll(state.items.map((item) => item.itemId));
      _hasInitializedSelection = true;
    }

    final specState = context.watch<CustomDesignSpecCubit>().state;
    final specSnapshot =
        specState is CustomDesignSpecSnapshot ? specState : null;

    final selectedItems =
        state.items.where((item) => _selectedItemIds.contains(item.itemId));
    final selectedTotalItems =
        selectedItems.fold(0, (sum, item) => sum + item.quantity);
    final selectedTotalPrice = selectedItems.fold(
      0.0,
      (sum, item) {
        final spec = item.customDesignId != null
            ? specSnapshot?.specOf(item.customDesignId!)
            : null;
        final printingPrice =
            resolvedDisplayPrintingPrice(item, spec: spec);
        return sum + (item.price + printingPrice) * item.quantity;
      },
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSelectAllHeader(state),
                SizedBox(height: AppSizes.paddingLg),
                _buildSectionHeader(
                  AppStrings.cartListTitle,
                  Icons.shopping_bag_outlined,
                ),
                SizedBox(height: AppSizes.radiusLg),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: AppSizes.radiusLg),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildCartItemCard(context, item);
                  },
                ),
                SizedBox(height: AppSizes.iconLg),
                CartOrderSummary(
                  selectedTotalItems: selectedTotalItems,
                  selectedTotalPrice: selectedTotalPrice,
                ),
                SizedBox(height: AppSizes.fontDisplay),
              ],
            ),
          ),
        ),
        CartStickyFooter(
          selectedTotalPrice: selectedTotalPrice,
          isEnabled: _selectedItemIds.isNotEmpty,
          onCheckout: () {
            context.pushNamed(
              AppRoutes.checkout,
              extra: _selectedItemIds.toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm + 2, color: AppColors.textSecondary),
        SizedBox(width: AppSizes.paddingSm),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: AppSizes.letterSpacingWide,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectAllHeader(CartLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.radiusLg,
        vertical: AppSizes.radiusLg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: AppSizes.iconMd,
            child: Checkbox(
              value: state.items.isNotEmpty &&
                  _selectedItemIds.length == state.items.length,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.paddingXs),
              ),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedItemIds.addAll(
                      state.items.map((item) => item.itemId),
                    );
                  } else {
                    _selectedItemIds.clear();
                  }
                });
              },
            ),
          ),
          SizedBox(width: AppSizes.radiusLg),
          Text(
            AppStrings.cartSelectAll(
              _selectedItemIds.length,
              state.items.length,
            ),
            style: GoogleFonts.lexend(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemEntity item) {
    return CartItemCard(
      item: item,
      isSelected: _selectedItemIds.contains(item.itemId),
      onToggleSelected: (value) {
        setState(() {
          if (value) {
            _selectedItemIds.add(item.itemId);
          } else {
            _selectedItemIds.remove(item.itemId);
          }
        });
      },
      onIncrementQuantity: () {
        context.read<CartCubit>().updateQuantity(
              variantId: item.variantId,
              quantity: item.quantity + 1,
              customDesignId: item.customDesignId,
            );
      },
      onDecrementQuantity: () {
        if (item.quantity > 1) {
          context.read<CartCubit>().updateQuantity(
                variantId: item.variantId,
                quantity: item.quantity - 1,
                customDesignId: item.customDesignId,
              );
        } else {
          _showRemoveConfirmation(context, item);
        }
      },
      onRemove: () => _showRemoveConfirmation(context, item),
      onCustomize: () {
        context.pushNamed(
          AppRoutes.productCustomizer,
          pathParameters: {'productId': item.productSlug},
          queryParameters: {
            'name': item.productName,
            'variantId': item.variantId.toString(),
            'quantity': item.quantity.toString(),
            'price': item.price.toString(),
          },
        );
      },
      onEditDesign: () {
        context.pushNamed(
          AppRoutes.productCustomizer,
          pathParameters: {'productId': item.productSlug},
          queryParameters: {
            'name': item.productName,
            'variantId': item.variantId.toString(),
            'quantity': item.quantity.toString(),
            'price': item.price.toString(),
            'itemId': item.itemId.toString(),
            'customDesignId': item.customDesignId?.toString() ?? '',
          },
        );
      },
      onRemoveDesign: () => _showRemoveDesignConfirmation(context, item),
    );
  }

  Future<void> _showRemoveConfirmation(
    BuildContext context,
    CartItemEntity item,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.cartRemoveItemTitle,
      message: AppStrings.cartRemoveItemMessage(item.productName),
      confirmLabel: AppStrings.cartRemoveItemConfirm,
    );
    if (confirmed && context.mounted) {
      context.read<CartCubit>().removeItem(item.itemId);
    }
  }

  Future<void> _showRemoveDesignConfirmation(
    BuildContext context,
    CartItemEntity item,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.cartRemoveDesignTitle,
      message: AppStrings.cartRemoveDesignMessage(item.productName),
      confirmLabel: AppStrings.cartRemoveDesignConfirm,
    );
    if (confirmed && context.mounted) {
      context.read<CartCubit>().removeDesignFromItem(
            itemId: item.itemId,
            variantId: item.variantId,
            quantity: item.quantity,
          );
    }
  }
}
