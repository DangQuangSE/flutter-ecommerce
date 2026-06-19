import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_error_state.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_order_summary.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_sticky_footer.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          'GIỎ HÀNG',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
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
      _selectedItemIds.addAll(state.items.map((e) => e.itemId));
      _hasInitializedSelection = true;
    }

    final selectedItems =
        state.items.where((e) => _selectedItemIds.contains(e.itemId)).toList();
    final selectedTotalItems =
        selectedItems.fold(0, (sum, e) => sum + e.quantity);
    final selectedTotalPrice = selectedItems.fold(
        0.0, (sum, e) => sum + (e.price + e.printingPrice) * e.quantity);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSelectAllHeader(state),
                const SizedBox(height: 20),
                _buildSectionHeader(
                    'DANH SÁCH GIỎ HÀNG', Icons.shopping_bag_outlined),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildCartItemCard(context, item);
                  },
                ),
                const SizedBox(height: 28),
                CartOrderSummary(
                  selectedTotalItems: selectedTotalItems,
                  selectedTotalPrice: selectedTotalPrice,
                ),
                const SizedBox(height: 32),
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
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectAllHeader(CartLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: state.items.isNotEmpty &&
                  _selectedItemIds.length == state.items.length,
              activeColor: AppColors.primary,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedItemIds
                        .addAll(state.items.map((e) => e.itemId));
                  } else {
                    _selectedItemIds.clear();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'CHỌN TẤT CẢ (${_selectedItemIds.length}/${state.items.length})',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
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
      onToggleSelected: (val) {
        setState(() {
          if (val) {
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

  void _showRemoveConfirmation(BuildContext context, CartItemEntity item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Xóa sản phẩm?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa ${item.productName} khỏi giỏ hàng?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'HỦY',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().removeItem(item.itemId);
              Navigator.pop(dialogCtx);
            },
            child: Text(
              'XÓA BỎ',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDesignConfirmation(
      BuildContext context, CartItemEntity item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Xóa thiết kế in ấn?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc muốn xóa thiết kế in ấn khỏi sản phẩm ${item.productName}? Thiết kế của bạn sẽ bị hủy và sản phẩm được trả về dạng nguyên bản.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'HỦY',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<CartCubit>().removeDesignFromItem(
                    itemId: item.itemId,
                    variantId: item.variantId,
                    quantity: item.quantity,
                  );
            },
            child: Text(
              'XÓA THIẾT KẾ',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
