import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/utils/price_formatter.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/utils/cart_item_pricing.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_item_actions.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/cart_item_design_section.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/custom_design_spec_entity.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_state.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final bool isSelected;
  final ValueChanged<bool> onToggleSelected;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;
  final VoidCallback onRemove;
  final VoidCallback? onCustomize;
  final VoidCallback? onEditDesign;
  final VoidCallback onRemoveDesign;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onToggleSelected,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
    required this.onRemove,
    this.onCustomize,
    this.onEditDesign,
    required this.onRemoveDesign,
  });

  @override
  Widget build(BuildContext context) {
    final designId = item.customDesignId;

    if (designId == null) {
      return _CartItemCardContent(
        item: item,
        isSelected: isSelected,
        onToggleSelected: onToggleSelected,
        onIncrementQuantity: onIncrementQuantity,
        onDecrementQuantity: onDecrementQuantity,
        onRemove: onRemove,
        onCustomize: onCustomize,
        onEditDesign: onEditDesign,
        onRemoveDesign: onRemoveDesign,
        displayPrintingPrice: item.printingPrice,
      );
    }

    return BlocSelector<CustomDesignSpecCubit, CustomDesignSpecState,
        CustomDesignSpecEntity?>(
      selector: (state) =>
          state is CustomDesignSpecSnapshot ? state.specOf(designId) : null,
      builder: (context, spec) {
        return _CartItemCardContent(
          item: item,
          isSelected: isSelected,
          onToggleSelected: onToggleSelected,
          onIncrementQuantity: onIncrementQuantity,
          onDecrementQuantity: onDecrementQuantity,
          onRemove: onRemove,
          onCustomize: onCustomize,
          onEditDesign: onEditDesign,
          onRemoveDesign: onRemoveDesign,
          displayPrintingPrice: resolvedDisplayPrintingPrice(item, spec: spec),
        );
      },
    );
  }
}

class _CartItemCardContent extends StatelessWidget {
  final CartItemEntity item;
  final bool isSelected;
  final ValueChanged<bool> onToggleSelected;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;
  final VoidCallback onRemove;
  final VoidCallback? onCustomize;
  final VoidCallback? onEditDesign;
  final VoidCallback onRemoveDesign;
  final double displayPrintingPrice;

  const _CartItemCardContent({
    required this.item,
    required this.isSelected,
    required this.onToggleSelected,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
    required this.onRemove,
    required this.onCustomize,
    required this.onEditDesign,
    required this.onRemoveDesign,
    required this.displayPrintingPrice,
  });

  @override
  Widget build(BuildContext context) {
    final category =
        item.isCustomizable ? 'TRANG BỊ HIỆU NĂNG' : 'THỜI TRANG THỂ THAO';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
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
                _buildCheckbox(),
                CartItemThumbnail(
                  imageUrl: item.imageUrl,
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetails(context, category, isDark),
                ),
              ],
            ),
          ),
          if (item.customDesignId != null)
            CartItemDesignSection(
              item: item,
              isDark: isDark,
              onEditDesign: onEditDesign,
              onRemoveDesign: onRemoveDesign,
            ),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 35, right: 8),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Checkbox(
          value: isSelected,
          activeColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) {
            if (val != null) onToggleSelected(val);
          },
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, String category, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(context, category),
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
          CartItemCustomBadge(displayPrintingPrice: displayPrintingPrice),
        ],
        const SizedBox(height: 10),
        _buildBottomRow(context, category),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context, String category) {
    return Row(
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatPrice(item.price + displayPrintingPrice),
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, String category) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        CartItemQuantityControl(
          quantity: item.quantity,
          onIncrement: onIncrementQuantity,
          onDecrement: onDecrementQuantity,
        ),
        if (category == 'TRANG BỊ HIỆU NĂNG' && item.customDesignId == null) ...[
          const SizedBox(width: 8),
          CartItemCustomizeButton(onCustomize: onCustomize),
        ],
        const Spacer(),
        CartItemDeleteButton(onRemove: onRemove),
      ],
    );
  }
}
