import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/product_carousel.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/color_selector.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/size_selector.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/collapsible_panel.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_state.dart';
import 'package:flutter_ecommerce/features/notification/presentation/widgets/notification_bell_icon.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_state.dart';

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
                    colorMap[v.colorName] = v.colorHex.isNotEmpty ? v.colorHex : '#000000';
                  }
                }
                final colorsList = colorMap.entries.map((e) => {'name': e.key, 'hex': e.value}).toList();
                final idx = colorsList.indexWhere((c) => c['name'] == firstVariant.colorName);
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
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          } else if (state is ProductDetailLoaded) {
            return _buildContent(context, state.product);
          } else if (state is ProductError) {
            return _buildErrorState(context, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product) {
    final String categoryLabel = product.categoryName.toUpperCase();

    final variants = product.variants ?? [];
    final colorMap = <String, String>{};
    final sizeList = <String>[];

    for (final variant in variants) {
      if (variant.colorName.isNotEmpty) {
        colorMap[variant.colorName] =
            variant.colorHex.isNotEmpty ? variant.colorHex : '#000000';
      }
      if (variant.size.isNotEmpty && !sizeList.contains(variant.size)) {
        sizeList.add(variant.size);
      }
    }

    final List<Map<String, String>> colors =
        colorMap.entries.map((e) => {'name': e.key, 'hex': e.value}).toList();

    final List<String> sizes = sizeList;

    final selectedColorIndex =
        _selectedColorIndex.clamp(0, colors.isEmpty ? 0 : colors.length - 1);
    final selectedColor =
        colors.isNotEmpty ? colors[selectedColorIndex]['name'] : null;

    final String selectedSize = sizes.contains(_selectedSize)
        ? _selectedSize
        : (sizes.isNotEmpty ? sizes.first : _selectedSize);

    ProductVariantEntity? matchingVariant;
    if (variants.isNotEmpty) {
      try {
        matchingVariant = variants.firstWhere(
          (v) => v.colorName == selectedColor && v.size == selectedSize,
          orElse: () => variants.firstWhere(
            (v) => v.size == selectedSize,
            orElse: () => variants.first,
          ),
        );
      } catch (_) {}
    }

    final priceToDisplay = matchingVariant != null
        ? (matchingVariant.salePrice ?? matchingVariant.originalPrice)
        : product.price;

    final double? originalPriceToDisplay = matchingVariant != null
        ? (matchingVariant.salePrice != null &&
                matchingVariant.salePrice! < matchingVariant.originalPrice
            ? matchingVariant.originalPrice
            : null)
        : (product.hasDiscount ? product.originalPrice : null);

    final stockToDisplay = matchingVariant != null
        ? matchingVariant.stockQuantity
        : product.stockQuantity;

    final bool isInStock = stockToDisplay > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductCarousel(
                    imageUrls: product.imageUrls.isNotEmpty
                        ? product.imageUrls
                        : (product.imageUrl.isNotEmpty
                            ? [product.imageUrl]
                            : []),
                  ),
                  _buildProductInfo(
                    product,
                    categoryLabel,
                    priceToDisplay,
                    originalPriceToDisplay,
                  ),
                  if (colors.isNotEmpty) ...[
                    _buildDivider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ColorSelector(
                        selectedColorIndex: selectedColorIndex,
                        colors: colors,
                        onColorSelected: (index) {
                          setState(() {
                            _selectedColorIndex = index;
                          });
                        },
                      ),
                    ),
                  ],
                  if (sizes.isNotEmpty) ...[
                    _buildDivider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizeSelector(
                        selectedSize: selectedSize,
                        sizes: sizes,
                        onSizeSelected: (size) {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                      ),
                    ),
                  ],
                  _buildDivider(),
                  _buildCollapsiblePanels(product),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomActionBar(
            context,
            product,
            matchingVariant,
            selectedSize,
            priceToDisplay,
            isInStock,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary, size: 24),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Transform(
          transform: Matrix4.skewX(-0.15),
          child: Text(
            AppStrings.brandName,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
              letterSpacing: -1.2,
            ),
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        const NotificationBellIcon(),
        BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            int cartCount = 0;
            if (cartState is CartLoaded) {
              cartCount = cartState.totalItems;
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => context.pushNamed(AppRoutes.cart),
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: AppColors.primary, size: 24),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        BlocBuilder<ChatCubit, ChatState>(
          builder: (context, chatState) {
            final unreadCount = context.read<ChatCubit>().totalUnreadMessages;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => context.pushNamed(AppRoutes.chatList),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent, // Safety Orange
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildProductInfo(
    ProductEntity product,
    String categoryLabel,
    double priceToDisplay,
    double? originalPriceToDisplay,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  product.brandName.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Text(
                categoryLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (originalPriceToDisplay != null)
                        Text(
                          _formatPrice(originalPriceToDisplay),
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Transform(
                        transform: Matrix4.skewX(-0.12),
                        child: Text(
                          _formatPrice(priceToDisplay),
                          style: GoogleFonts.lexend(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (originalPriceToDisplay != null &&
                      originalPriceToDisplay > priceToDisplay) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Giảm ${(((originalPriceToDisplay - priceToDisplay) / originalPriceToDisplay) * 100).round()}%',
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (product.reviewCount > 0)
                Row(
                  children: [
                    Row(
                      children: _buildRatingStars(product.averageRating),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviewCount})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  AppStrings.noRatingYet,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsiblePanels(ProductEntity product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          CollapsiblePanel(
            title: AppStrings.specsTitle,
            child: Text(
              product.description.isNotEmpty
                  ? product.description
                  : AppStrings.noProductDescription,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          CollapsiblePanel(
            title: AppStrings.reviewsTitle(product.reviewCount),
            child: BlocBuilder<ReviewCubit, ReviewState>(
              builder: (context, state) {
                if (state is ReviewLoading || state is ReviewInitial) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (state is ReviewError) {
                  return Text(
                    AppStrings.reviewsLoadError,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  );
                }
                if (state is ReviewLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < state.reviews.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 16, color: Color(0xFFE8E8ED)),
                        _buildReviewRow(state.reviews[i]),
                      ],
                    ],
                  );
                }
                return Text(
                  AppStrings.noReviewsYet,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                );
              },
            ),
          ),
          CollapsiblePanel(
            title: AppStrings.returnPolicyTitle,
            child: BlocBuilder<SiteSettingCubit, SiteSettingState>(
              builder: (context, state) {
                final content = switch (state) {
                  SiteSettingLoaded(:final settings)
                      when settings.returnPolicy.isEmpty =>
                    AppStrings.returnPolicyEmpty,
                  SiteSettingLoaded() => state.settings.returnPolicy,
                  SiteSettingError() => AppStrings.returnPolicyLoadError,
                  _ => AppStrings.returnPolicyLoading,
                };
                return Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(ReviewEntity review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              review.userName,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: List.generate(
                  5,
                  (index) => Icon(
                        Icons.star_rounded,
                        color: index < review.rating
                            ? AppColors.accent
                            : const Color(0xFFC1C6D7),
                        size: 14,
                      )),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          review.comment,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRatingStars(double rating) {
    return List.generate(5, (index) {
      final remainder = rating - index;
      final icon = remainder >= 1
          ? Icons.star_rounded
          : remainder >= 0.5
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded;
      return Icon(icon, color: AppColors.accent, size: 18);
    });
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    ProductEntity product,
    ProductVariantEntity? matchingVariant,
    String selectedSize,
    double priceToDisplay,
    bool isInStock,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isFavorited = !_isFavorited;
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isFavorited
                          ? AppStrings.addedToWishlist
                          : AppStrings.removedFromWishlist,
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isFavorited ? Colors.red : const Color(0xFFC1C6D7),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFavorited ? Colors.red : AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: !isInStock
                    ? null
                    : () {
                        final targetVariantId = matchingVariant?.id ??
                            (product.variants?.isNotEmpty == true
                                ? product.variants!.first.id
                                : 1);
                        final custId = context
                            .read<CustomizerCubit>()
                            .getCustomizationOrDefault(product.id)
                            .customDesignId;
                        context.read<CartCubit>().addItem(
                              variantId: targetVariantId,
                              quantity: 1,
                              customDesignId: custId,
                            );

                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    AppStrings.addedToCartMessage(
                                        product.name, selectedSize),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            action: SnackBarAction(
                              label: AppStrings.viewCart,
                              textColor: Colors.white,
                              onPressed: () =>
                                  context.pushNamed(AppRoutes.cart),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isInStock ? AppColors.accent : Colors.grey[400],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isInStock
                          ? Icons.shopping_bag_outlined
                          : Icons.remove_shopping_cart_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInStock ? AppStrings.addToCart : AppStrings.outOfStock,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                AppStrings.productDetailLoadError,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<ProductBloc>()
                      .add(ProductDetailRequested(widget.productId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatStr = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < formatStr.length; i++) {
      buffer.write(formatStr[i]);
      if ((formatStr.length - 1 - i) % 3 == 0 && i != formatStr.length - 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}
