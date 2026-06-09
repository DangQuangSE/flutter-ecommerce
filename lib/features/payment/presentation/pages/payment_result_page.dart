import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class PaymentResultPage extends StatelessWidget {
  final bool success;
  final String message;

  const PaymentResultPage({
    super.key,
    required this.success,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 72,
                color: success ? AppColors.success : AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                success ? 'Thanh toán thành công' : 'Thanh toán thất bại',
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.inter(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(AppRoutes.home),
                  child: const Text('VỀ TRANG CHỦ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
