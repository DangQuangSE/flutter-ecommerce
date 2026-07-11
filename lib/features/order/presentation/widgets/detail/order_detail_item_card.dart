import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/order_review_eligibility.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_item_entity.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/order_price_formatter.dart';

class OrderDetailItemCard extends StatelessWidget {
  final OrderEntity order;
  final OrderItemEntity item;
  final VoidCallback onReviewRequested;

  const OrderDetailItemCard({
    super.key,
    required this.order,
    required this.item,
    required this.onReviewRequested,
  });

  @override
  Widget build(BuildContext context) {
    final canReview = OrderReviewEligibility.canReview(
      orderStatus: order.status,
      isReviewed: item.isReviewed,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderItemImage(imageUrl: item.imageUrl),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${AppStrings.orderSizeLabel}: ${item.size} · '
                  '${AppStrings.orderQuantityLabel}: ${item.quantity}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.hasCustomPrinting) ...[
                  SizedBox(height: 4),
                  Text(
                    AppStrings.orderCustomPrinting(
                      item.customDesignId!,
                      formatOrderPrice(item.printingLineTotal),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed(
                      AppRoutes.orderDesignViewer,
                      pathParameters: {'orderId': order.id.toString(), 'designId': item.customDesignId.toString()},
                    ),
                    child: const Text(AppStrings.designViewerViewAction),
                  ),
                ],
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatOrderPrice(item.lineTotal),
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (canReview)
                      _WriteReviewButton(onPressed: onReviewRequested)
                    else if (item.isReviewed)
                      Text(
                        AppStrings.orderReviewedLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _WriteReviewButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
      ),
      child: Text(
        AppStrings.orderWriteReviewAction,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _OrderItemImage extends StatelessWidget {
  final String? imageUrl;

  const _OrderItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const _ImageFallback(),
            )
          : const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }
}
