import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginGoogleButton extends StatefulWidget {
  const LoginGoogleButton({super.key});

  @override
  State<LoginGoogleButton> createState() => _LoginGoogleButtonState();
}

class _LoginGoogleButtonState extends State<LoginGoogleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        AppSnackBar.show(
          context,
          message: AppStrings.googleSignInSetup,
          type: AppSnackBarType.info,
        );
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: const Size(20, 20),
                painter: const _GoogleLogoPainter(),
              ),
              const SizedBox(width: 12),
              Text(
                'Tiếp tục với Google',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double length = size.width;
    final double thickness = length / 4.5;
    final bounds = Rect.fromLTWH(0, 0, length, length);
    final drawBounds = bounds.deflate(thickness / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    // Helper to draw segments
    void drawArc(double startAngle, double sweepAngle, Color color) {
      canvas.drawArc(drawBounds, startAngle, sweepAngle, false, paint..color = color);
    }

    // Drawing the arcs using official Google colors
    drawArc(3.5, 1.9, const Color(0xFFEA4335));   // Red (Top)
    drawArc(2.5, 1.0, const Color(0xFFFBBC05));   // Yellow (Left)
    drawArc(0.9, 1.6, const Color(0xFF34A853));   // Green (Bottom)
    drawArc(-0.18, 1.1, const Color(0xFF4285F4)); // Blue (Right)

    // Draw the horizontal bar to complete the "G"
    final center = bounds.center;
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - (thickness / 2),
        center.dx + (length / 2),
        center.dy + (thickness / 2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
