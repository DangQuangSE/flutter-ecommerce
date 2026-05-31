import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class PaymentQrCard extends StatefulWidget {
  final String formattedTotal;

  const PaymentQrCard({
    super.key,
    required this.formattedTotal,
  });

  @override
  State<PaymentQrCard> createState() => _PaymentQrCardState();
}

class _PaymentQrCardState extends State<PaymentQrCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vietcombank Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_rounded,
                color: Color(0xFF009933),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'VIETCOMBANK PAY',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),

          // QR Code Frame with Animated Scanner
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFC1C6D7).withValues(alpha: 0.5),
              ),
            ),
            child: Stack(
              children: [
                // Mock QR Code Image
                Center(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB1nET59e0SbYD42twWPG-ZURJoyWIqBt5NiEeSZ6hdyriPYLMpPw22pjAkY-Qdf9mf5NAb7anAIw5_Fcec-7F7L5M_TcSUslwnlxbYh3_SzhS1B56nSO8Rs8GWxAP7piNtkh1jGFi-SWs2-3F1iW88D54J6AiX0Y_2Y6YS8u-JVz3Ogp3v8zKqAjwFo-fpESSmZfRgQ2GvOP_ISB1kCRm_kE5Dvz5WK1WxXVvCSChh5RRiq0HMk1OY55XnbObugxVzlohYt0Zr054',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white,
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: 100,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Animated Scanning Laser Line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(0, -1 + (_scanAnimation.value * 2)),
                      child: Container(
                        width: double.infinity,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.accent, // Safety Orange laser
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instructions Text
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Quét mã bằng ứng dụng ngân hàng để chuyển chính xác '),
                TextSpan(
                  text: widget.formattedTotal,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: '. Đơn hàng sẽ được xử lý tự động.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
