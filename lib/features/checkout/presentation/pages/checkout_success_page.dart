import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderReference = '#SP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Animated/Glow Success Icon Bounding Box
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF009933).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF009933).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFF009933),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Center(
                child: Transform(
                  transform: Matrix4.skewX(-0.15),
                  child: Text(
                    'XÁC NHẬN THÀNH CÔNG',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Đơn hàng của bạn đã được ghi nhận hệ thống thành công và đang được chuẩn bị để giao hỏa tốc.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Transaction Detail Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInvoiceRow('Mã đơn hàng', orderReference, isBold: true),
                    const SizedBox(height: 12),
                    _buildInvoiceRow('Thời gian giao dự kiến', 'Hôm nay (Trong 2-4 giờ)', isSuccessColor: true),
                    const SizedBox(height: 12),
                    _buildInvoiceRow('Hình thức thanh toán', 'Thanh toán đã ghi nhận'),
                    const SizedBox(height: 12),
                    _buildInvoiceRow('Trạng thái đơn hàng', 'Đang chuẩn bị hàng'),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Button to Go Back
              ElevatedButton(
                onPressed: () {
                  context.goNamed(AppRoutes.productList);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent, // Safety Orange
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TIẾP TỤC MUA SẮM',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.shopping_bag_outlined, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSuccessColor = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isSuccessColor
                ? const Color(0xFF009933)
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
