import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';

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
              return _buildEmptyState();
            }
            return _buildCartContent(context, state);
          } else if (state is CartError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Transform(
              transform: Matrix4.skewX(-0.12),
              child: Text(
                'GIỎ HÀNG TRỐNG',
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn chưa thêm bất kỳ sản phẩm nào vào giỏ hàng. Hãy khám phá bộ sưu tập thể thao Pro ngay!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRoutes.productList),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'TIẾP TỤC MUA SẮM',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    if (!_hasInitializedSelection) {
      _selectedItemIds.clear();
      _selectedItemIds.addAll(state.items.map((e) => e.itemId));
      _hasInitializedSelection = true;
    }

    final selectedItems = state.items.where((e) => _selectedItemIds.contains(e.itemId)).toList();
    final selectedTotalItems = selectedItems.fold(0, (sum, e) => sum + e.quantity);
    final selectedTotalPrice = selectedItems.fold(0.0, (sum, e) => sum + (e.price + e.printingPrice) * e.quantity);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Select All Header Card
                Container(
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
                          value: state.items.isNotEmpty && _selectedItemIds.length == state.items.length,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedItemIds.addAll(state.items.map((e) => e.itemId));
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
                ),
                const SizedBox(height: 20),

                // Cart Items Section
                _buildSectionHeader('DANH SÁCH GIỎ HÀNG', Icons.shopping_bag_outlined),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildCartItemCard(context, item);
                  },
                ),
                const SizedBox(height: 28),

                // Summary Section
                _buildOrderSummary(selectedTotalItems, selectedTotalPrice),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildStickyFooter(context, selectedTotalPrice),
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

  Widget _buildCartItemCard(BuildContext context, CartItemEntity item) {
    final String category = item.isCustomizable ? 'TRANG BỊ HIỆU NĂNG' : 'THỜI TRANG THỂ THAO';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox select
                Padding(
                  padding: const EdgeInsets.only(top: 35, right: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _selectedItemIds.contains(item.itemId),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedItemIds.add(item.itemId);
                          } else {
                            _selectedItemIds.remove(item.itemId);
                          }
                        });
                      },
                    ),
                  ),
                ),

                // Thumbnail Box
                Container(
                  width: 80,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0058BC),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.productName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatPrice(item.price),
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Màu sắc: ${item.color ?? "N/A"}    Kích cỡ: ${item.size ?? "N/A"}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      if (item.customDesignId != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFADCCF6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.build_outlined, size: 10, color: Color(0xFF0058BC)),
                              const SizedBox(width: 4),
                              Text(
                                'IN TÙY CHỌN: +${_formatPrice(item.printingPrice)}',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0058BC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      // Price + quantity row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFC1C6D7)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
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
                                  child: const SizedBox(width: 28, height: 28, child: Icon(Icons.remove, size: 12)),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<CartCubit>().updateQuantity(
                                          variantId: item.variantId,
                                          quantity: item.quantity + 1,
                                          customDesignId: item.customDesignId,
                                        );
                                  },
                                  child: const SizedBox(width: 28, height: 28, child: Icon(Icons.add, size: 12)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (category == 'TRANG BỊ HIỆU NĂNG' && item.customDesignId == null) ...[
                            GestureDetector(
                              onTap: () {
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary, width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.brush_rounded, size: 12, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'CUSTOM',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showRemoveConfirmation(context, item),
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'XÓA',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.customDesignId != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              height: 1,
              color: const Color(0xFFC1C6D7).withValues(alpha: 0.15),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.build_outlined, size: 12, color: Color(0xFF0058BC)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'CHI TIẾT THIẾT KẾ IN ẤN',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
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
                        child: Text(
                          'CHỈNH SỬA THIẾT KẾ',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0058BC),
                          ),
                        ),
                      ),
                      Text(
                        '  |  ',
                        style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => _showRemoveDesignConfirmation(context, item),
                        child: Text(
                          'XÓA THIẾT KẾ',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFC1C6D7).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item.designImageUrl ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.broken_image_outlined, size: 14, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomDesignSpecCard(
                            customDesignId: item.customDesignId!,
                            fallbackPrintingPrice: item.printingPrice,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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



  Widget _buildOrderSummary(int selectedTotalItems, double selectedTotalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính ($selectedTotalItems sản phẩm)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatPrice(selectedTotalPrice),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao hàng hỏa tốc',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Miễn phí',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF009933),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TỔNG CỘNG',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              Transform(
                transform: Matrix4.skewX(-0.12),
                child: Text(
                  _formatPrice(selectedTotalPrice),
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, double selectedTotalPrice) {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedItemIds.isEmpty
                ? null
                : () {
                    context.pushNamed(
                      AppRoutes.checkout,
                      extra: _selectedItemIds.toList(),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent, // Safety Orange
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFC1C6D7),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TIẾN HÀNH THANH TOÁN',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thông tin giỏ hàng.',
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
                context.read<CartCubit>().loadCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDesignConfirmation(BuildContext context, CartItemEntity item) {
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

class CustomDesignSpecCard extends StatefulWidget {
  final int customDesignId;
  final double fallbackPrintingPrice;

  const CustomDesignSpecCard({
    super.key,
    required this.customDesignId,
    required this.fallbackPrintingPrice,
  });

  @override
  State<CustomDesignSpecCard> createState() => _CustomDesignSpecCardState();
}

class _CustomDesignSpecCardState extends State<CustomDesignSpecCard> {
  bool _isLoading = true;
  String? _materialName;
  int _numTextLines = 0;
  int _numImages = 0;
  double _totalPrintingPrice = 0.0;
  double _materialBasePrice = 0.0;
  double _textUnitPrice = 0.0;
  double _imageUnitPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDesignDetails();
  }

  Future<void> _loadDesignDetails() async {
    try {
      final dioClient = sl<DioClient>();
      final customDesignRepo = sl<CustomDesignRepository>();
      
      final results = await Future.wait([
        dioClient.dio.get('/api/custom-designs/${widget.customDesignId}'),
        customDesignRepo.getPrintingConfigs(),
      ]);

      final designResponse = results[0] as Response;
      final configResult = results[1] as Result<PrintingConfigEntity>;

      final body = designResponse.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      final materialId = (data['printingMaterialId'] as num?)?.toInt();
      final materialName = data['printingMaterialName'] as String?;
      final numTextLines = (data['numTextLines'] as num? ?? 0).toInt();
      final numImages = (data['numImages'] as num? ?? 0).toInt();
      final totalPrintingPrice = (data['totalPrintingPrice'] as num? ?? 0.0).toDouble();

      double materialBasePrice = 0.0;
      double textUnitPrice = 0.0;
      double imageUnitPrice = 0.0;

      if (configResult is Success<PrintingConfigEntity>) {
        final config = configResult.data;
        if (materialId != null) {
          final matchedMat = config.materials.firstWhere(
            (m) => m.id == materialId,
            orElse: () => config.materials.firstWhere(
              (m) => m.name.toLowerCase() == materialName?.toLowerCase(),
              orElse: () => const PrintingMaterialEntity(id: -1, name: '', description: '', basePrice: 0.0, isActive: false),
            ),
          );
          if (matchedMat.id != -1) {
            materialBasePrice = matchedMat.basePrice;
          }
        }
        
        for (final pc in config.priceConfigs) {
          if (pc.type == 'TEXT') {
            textUnitPrice = pc.unitPrice;
          } else if (pc.type == 'IMAGE') {
            imageUnitPrice = pc.unitPrice;
          }
        }
      }

      if (mounted) {
        setState(() {
          _materialName = materialName;
          _numTextLines = numTextLines;
          _numImages = numImages;
          _totalPrintingPrice = totalPrintingPrice;
          _materialBasePrice = materialBasePrice;
          _textUnitPrice = textUnitPrice;
          _imageUnitPrice = imageUnitPrice;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom design details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0058BC))),
          ),
        ),
      );
    }

    final materialText = _materialName ?? 'N/A';
    final textLines = _numTextLines;
    final images = _numImages;
    final printingPrice = _totalPrintingPrice > 0 ? _totalPrintingPrice : widget.fallbackPrintingPrice;

    final textCost = textLines * _textUnitPrice;
    final imageCost = images * _imageUnitPrice;

    final materialValueText = _materialBasePrice > 0
        ? '${materialText.toUpperCase()} (+${_formatPrice(_materialBasePrice)})'
        : materialText.toUpperCase();
    final textValueText = _textUnitPrice > 0
        ? '$textLines lớp (+${_formatPrice(textCost)})'
        : '$textLines lớp';
    final imageValueText = _imageUnitPrice > 0
        ? '$images ảnh (+${_formatPrice(imageCost)})'
        : '$images ảnh';

    return Column(
      children: [
        _buildSpecRow('Chất liệu tuyển chọn:', materialValueText, isBoldValue: true),
        const SizedBox(height: 4),
        _buildSpecRow('Số lớp chữ in thêm:', textValueText),
        const SizedBox(height: 4),
        _buildSpecRow('Số logo tải lên:', imageValueText),
        const SizedBox(height: 4),
        Container(height: 1, color: const Color(0xFFC1C6D7).withValues(alpha: 0.15)),
        const SizedBox(height: 4),
        _buildSpecRow(
          'Tổng cộng chi phí in:',
          '+${_formatPrice(printingPrice)}',
          isBlueValue: true,
          isBoldValue: true,
        ),
        if (_textUnitPrice > 0 && _imageUnitPrice > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF0058BC)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Công thức tính giá in ấn: Giá phôi in + (Số lớp chữ x ${_formatPrice(_textUnitPrice)}/lớp) + (Số logo x ${_formatPrice(_imageUnitPrice)}/ảnh)',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0058BC),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isBoldValue = false, bool isBlueValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
              color: isBlueValue ? const Color(0xFF0058BC) : AppColors.textPrimary,
            ),
          ),
        ),
      ],
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
