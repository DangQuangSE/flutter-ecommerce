import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';

class AdminOrderCard extends StatelessWidget {
  final AdminOrderEntity order;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeText) = OrderStatusLabel.badgeColors(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.displayCode,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    order.primaryProductName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    order.phoneNumber,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(order.totalAmount),
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    OrderStatusLabel.vi(order.status),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
