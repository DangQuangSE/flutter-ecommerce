import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';

/// Animated, tappable menu row used in both user and admin profile screens.
class ProfileMenuRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool enabled;

  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.enabled = true,
  });

  @override
  State<ProfileMenuRow> createState() => _ProfileMenuRowState();
}

class _ProfileMenuRowState extends State<ProfileMenuRow> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? AppColors.textPrimary;
    final labelColor = widget.labelColor ?? AppColors.textPrimary;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _scale = 0.97) : null,
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _scale = 1.0);
                widget.onTap();
              }
            : null,
        onTapCancel: widget.enabled ? () => setState(() => _scale = 1.0) : null,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.fastLinearToSlowEaseIn,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 20, color: iconColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: widget.iconColor ?? AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
