import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// A playful truck loading animation with "Sport Pro" branding.
/// Use [TruckLoadingOverlay] for full-page loading, or [TruckLoader] standalone.
class TruckLoader extends StatefulWidget {
  final double width;
  final double height;

  const TruckLoader({
    super.key,
    this.width = 200,
    this.height = 120,
  });

  @override
  State<TruckLoader> createState() => _TruckLoaderState();
}

class _TruckLoaderState extends State<TruckLoader>
    with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final AnimationController _roadCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _roadCtrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _roadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceCtrl, _roadCtrl]),
        builder: (context, _) {
          return CustomPaint(
            painter: _TruckPainter(
              bounceProgress: _bounceCtrl.value,
              roadProgress: _roadCtrl.value,
            ),
          );
        },
      ),
    );
  }
}

/// Full-screen loading overlay with the truck animation centered.
class TruckLoadingOverlay extends StatelessWidget {
  final String? message;

  const TruckLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TruckLoader(width: 220, height: 130),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TruckPainter extends CustomPainter {
  final double bounceProgress; // 0..1
  final double roadProgress; // 0..1

  _TruckPainter({
    required this.bounceProgress,
    required this.roadProgress,
  });

  // ── Palette ──────────────────────────────────────────────────────────
  static const _bodyFill = Color(0xFFDFDFDF);
  static const _cabFill = Color(0xFFF83D3D);
  static const _cabWindow = Color(0xFF7D7C7C);
  static const _black = Color(0xFF282828);
  static const _white = Colors.white;
  static const _tireInner = Color(0xFFDFDFDF);
  static const _headlight = Color(0xFFFFFCAB);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    // ── Dimensions (proportional to original 198×93 viewBox) ──────────
    final scale = w / 200;
    final bodyW = 121.0 * scale;
    final bodyH = 90.0 * scale;
    final bodyX = 6.5 * scale;
    final bodyY = 8.0 * scale;

    final cabW = 47.0 * scale;
    final cabH = 69.0 * scale;
    final cabX = bodyX + bodyW - 1.5 * scale;
    final cabY = bodyY + 14.0 * scale;

    final wheelR = 12.0 * scale;
    final wheelY = bodyY + bodyH - 2.0 * scale;
    final wheelLeftX = bodyX + 22.0 * scale;
    final wheelRightX = cabX + cabW - 18.0 * scale;

    // ── Bounce offset ─────────────────────────────────────────────────
    final bounce = math.sin(bounceProgress * math.pi) * 3.0 * scale;

    canvas.save();
    canvas.translate(0, -bounce);

    // ── Road ──────────────────────────────────────────────────────────
    final roadY = wheelY + wheelR + 2.0 * scale;
    final roadPaint = Paint()
      ..color = _black
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(bodyX - 10 * scale, roadY),
      Offset(cabX + cabW + 40 * scale, roadY),
      roadPaint,
    );

    // Road dashes
    final dashPaint = Paint()
      ..color = _white
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round;
    final dashOffset = roadProgress * 160.0 * scale;
    for (double dx = -40; dx < 200; dx += 30) {
      final x = cabX + cabW + dx * scale - dashOffset;
      if (x > bodyX - 20 * scale && x < cabX + cabW + 50 * scale) {
        canvas.drawLine(
          Offset(x, roadY - 0.75 * scale),
          Offset(x + 12 * scale, roadY - 0.75 * scale),
          dashPaint,
        );
      }
    }

    // ── Lamp post (moves with road) ───────────────────────────────────
    final lampX = cabX + cabW + 30 * scale - dashOffset * 0.8;
    final lampBaseY = roadY;
    final lampH = 70.0 * scale;
    final lampPaint = Paint()
      ..color = _black
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(lampX, lampBaseY),
      Offset(lampX, lampBaseY - lampH),
      lampPaint,
    );
    // Lamp head
    final lampHeadPaint = Paint()..color = _headlight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lampX - 4 * scale, lampBaseY - lampH - 6 * scale, 8 * scale, 6 * scale),
        Radius.circular(2 * scale),
      ),
      lampHeadPaint,
    );

    // ── Truck body (gray box) ─────────────────────────────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyX, bodyY, bodyW, bodyH),
      Radius.circular(3 * scale),
    );
    canvas.drawRRect(bodyRect, Paint()..color = _bodyFill);
    canvas.drawRRect(bodyRect, Paint()
      ..color = _black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale);

    // ── Sport Pro text on truck body ──────────────────────────────────
    final textPainter = TextPainter(
      text: TextSpan(
        text: AppStrings.truckLoaderBrand,
        style: TextStyle(
          color: _black.withValues(alpha: 0.7),
          fontSize: 16.0 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textX = bodyX + (bodyW - textPainter.width) / 2;
    final textY = bodyY + (bodyH - textPainter.height) / 2 - 4 * scale;
    textPainter.paint(canvas, Offset(textX, textY));

    // ── Cab (red) ─────────────────────────────────────────────────────
    final cabPath = Path()
      ..moveTo(cabX, cabY)
      ..lineTo(cabX + cabW - 10 * scale, cabY)
      ..lineTo(cabX + cabW, cabY + 20 * scale)
      ..lineTo(cabX + cabW, cabY + cabH)
      ..lineTo(cabX, cabY + cabH)
      ..close();
    canvas.drawPath(cabPath, Paint()..color = _cabFill);
    canvas.drawPath(cabPath, Paint()
      ..color = _black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale);

    // ── Cab window ────────────────────────────────────────────────────
    final winPath = Path()
      ..moveTo(cabX + 4 * scale, cabY + 6 * scale)
      ..lineTo(cabX + cabW - 14 * scale, cabY + 6 * scale)
      ..lineTo(cabX + cabW - 6 * scale, cabY + 20 * scale)
      ..lineTo(cabX + 4 * scale, cabY + 20 * scale)
      ..close();
    canvas.drawPath(winPath, Paint()..color = _cabWindow);
    canvas.drawPath(winPath, Paint()
      ..color = _black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale);

    // ── Headlight ─────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cabX + cabW - 2 * scale, cabY + 44 * scale, 5 * scale, 7 * scale),
        Radius.circular(1 * scale),
      ),
      Paint()..color = _headlight,
    );

    // ── Front bumper ──────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cabX + cabW - 2 * scale, cabY + cabH - 8 * scale, 4 * scale, 10 * scale),
        Radius.circular(1 * scale),
      ),
      Paint()..color = _black,
    );

    // ── Rear guard ────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyX - 3 * scale, bodyY + bodyH - 8 * scale, 5 * scale, 6 * scale),
        Radius.circular(1 * scale),
      ),
      Paint()..color = _black,
    );

    canvas.restore();

    // ── Wheels (not affected by bounce) ───────────────────────────────
    _drawWheel(canvas, wheelLeftX, wheelY, wheelR, scale);
    _drawWheel(canvas, wheelRightX, wheelY, wheelR, scale);
  }

  void _drawWheel(Canvas canvas, double cx, double cy, double r, double scale) {
    // Outer tire
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = _black,
    );
    // Inner hub
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.5,
      Paint()..color = _tireInner,
    );
  }

  @override
  bool shouldRepaint(covariant _TruckPainter old) =>
      old.bounceProgress != bounceProgress || old.roadProgress != roadProgress;
}
