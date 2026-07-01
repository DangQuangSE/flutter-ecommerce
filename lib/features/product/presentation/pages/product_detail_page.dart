import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/detail/product_detail_content.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/detail/product_detail_error_view.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedColorIndex = 0;
  String _selectedSize = '';
  bool _isFavorited = false;
  bool _reviewsRequested = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductBloc>().add(ProductDetailRequested(widget.productId));
      context.read<CartCubit>().loadCart();
      context.read<SiteSettingCubit>().loadSettings();
    });
  }

  void _toggleFavorite(BuildContext context) {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    AppSnackBar.show(
      context,
      message: _isFavorited
          ? AppStrings.addedToWishlist
          : AppStrings.removedFromWishlist,
      duration: const Duration(seconds: 1),
    );
  }

  void _addToCart(
    BuildContext context,
    ProductEntity product,
    ProductVariantEntity? matchingVariant,
    String selectedSize,
  ) {
    final targetVariantId = matchingVariant?.id ??
        (product.variants?.isNotEmpty == true ? product.variants!.first.id : 1);
    final custId = context
        .read<CustomizerCubit>()
        .getCustomizationOrDefault(product.id)
        .customDesignId;
    context.read<CartCubit>().addItem(
          variantId: targetVariantId,
          quantity: 1,
          customDesignId: custId,
        );

    AppSnackBar.show(
      context,
      message: AppStrings.addedToCartMessage(product.name, selectedSize),
      type: AppSnackBarType.success,
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      actionLabel: AppStrings.viewCart,
      onAction: () => context.pushNamed(AppRoutes.cart),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductDetailLoaded) {
            if (!_reviewsRequested && state.product.numericId != null) {
              _reviewsRequested = true;
              context.read<ReviewCubit>().loadReviews(state.product.numericId!);
            }
            final variants = state.product.variants ?? [];
            if (variants.isNotEmpty) {
              final firstVariant = variants.first;
              setState(() {
                _selectedSize = firstVariant.size;

                final colorMap = <String, String>{};
                for (final v in variants) {
                  if (v.colorName.isNotEmpty) {
                    colorMap[v.colorName] =
                        v.colorHex.isNotEmpty ? v.colorHex : '#000000';
                  }
                }
                final colorsList = colorMap.entries
                    .map((e) => {'name': e.key, 'hex': e.value})
                    .toList();
                final idx = colorsList
                    .indexWhere((c) => c['name'] == firstVariant.colorName);
                if (idx != -1) {
                  _selectedColorIndex = idx;
                }
              });
            }
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Scaffold(
              body: AppLoadingView(),
            );
          } else if (state is ProductDetailLoaded) {
            return _buildContent(context, state.product);
          } else if (state is ProductError) {
            return ProductDetailErrorView(
              message: state.message,
              onRetry: () {
                context
                    .read<ProductBloc>()
                    .add(ProductDetailRequested(widget.productId));
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product) {
    return ProductDetailContent(
      product: product,
      selectedColorIndex: _selectedColorIndex,
      selectedSize: _selectedSize,
      isFavorited: _isFavorited,
      onColorSelected: (index) {
        setState(() {
          _selectedColorIndex = index;
        });
      },
      onSizeSelected: (size) {
        setState(() {
          _selectedSize = size;
        });
      },
      onToggleFavorite: () => _toggleFavorite(context),
      onAddToCart: (matchingVariant, selectedSize) => _addToCart(
        context,
        product,
        matchingVariant,
        selectedSize,
      ),
    );
  }
}
