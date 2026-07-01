import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class AdminLocationTab extends StatelessWidget {
  final VoidCallback onBackToDashboard;

  const AdminLocationTab({super.key, required this.onBackToDashboard});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBackToDashboard,
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.textPrimary),
                ),
                SizedBox(width: 16),
                Text(
                  AppStrings.adminLocationTitle,
                  style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: MapMockGridPainter()),
                      ),
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, val, child) {
                            return Transform.translate(
                              offset: Offset(0, -20 * (1.0 - val)),
                              child: Transform.scale(
                                scale: val,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardTheme.color,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.12),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4)),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Text(
                                        AppStrings.adminShowroomName,
                                        style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Icon(Icons.location_on_rounded,
                                        size: 48, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(AppStrings.adminShowroomLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                        ),
                        SizedBox(height: 8),
                        Text(AppStrings.adminShowroomName,
                            style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        SizedBox(height: 14),
                        _infoRow(Icons.location_on_rounded,
                            '123 Nguyễn Văn Linh, Quận 7, TP. Hồ Chí Minh'),
                        SizedBox(height: 10),
                        _infoRow(Icons.phone_rounded, '0909 123 456'),
                        SizedBox(height: 10),
                        _infoRow(
                            Icons.access_time_filled_rounded, '08:00 - 21:00'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}

class MapMockGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    final secondaryRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final riverPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..strokeWidth = 40.0
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width * 0.8,
          size.height * 0.5)
      ..lineTo(size.width, size.height * 0.55);
    canvas.drawPath(riverPath, riverPaint);

    canvas.drawLine(Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.4, size.height), roadPaint);

    canvas.drawLine(Offset(0, size.height * 0.8),
        Offset(size.width, size.height * 0.75), secondaryRoadPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0),
        Offset(size.width * 0.75, size.height), secondaryRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.1),
        Offset(size.width * 0.5, size.height * 0.35), secondaryRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
