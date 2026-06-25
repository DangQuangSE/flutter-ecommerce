import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingSlide extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final String imageUrl;
  final double scrollOffset;

  const OnboardingSlide({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Slide-specific colors for shadow glows
    final List<Color> themeColors = [
      const Color(0xFF1A73E8), // Slide 0: Blue
      const Color(0xFF6D28D9), // Slide 1: Purple
      const Color(0xFFEA580C), // Slide 2: Orange
    ];
    final Color activeColor = themeColors[index.clamp(0, 2)];

    // Build the slide layout based on its index (Composition Variety)
    if (index == 0) {
      return _buildSlide0(context, size, activeColor);
    } else if (index == 1) {
      return _buildSlide1(context, size, activeColor);
    } else {
      return _buildSlide2(context, size, activeColor);
    }
  }

  // SLIDE 0: Left-Aligned Text + Tech Tags + Bottom-Right 3D Mockup
  Widget _buildSlide0(BuildContext context, Size size, Color activeColor) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // Headline in Lexend (fixed diacritics)
          SizedBox(
            width: size.width * 0.85,
            child: Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 1.15,
                letterSpacing: -1.2,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Double-Bezel Glassmorphic Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          height: 1.6,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Rich feature tags
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTechChip('✦ Thanh toán VNPay', activeColor),
                            const SizedBox(width: 8),
                            _buildTechChip('✦ Bộ lọc thông minh', activeColor),
                            const SizedBox(width: 8),
                            _buildTechChip('✦ Catalog đa dạng', activeColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3D Mockup Image Container
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -16 - (scrollOffset * 45), // Parallax translation offset
                  bottom: -10,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(0.06 - scrollOffset * 0.15)
                      ..rotateX(scrollOffset * 0.1)
                      ..rotateZ(-0.06 + scrollOffset * 0.04),
                    alignment: Alignment.center,
                    child: _buildImage(size, activeColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SLIDE 1: Top-Left Image + Bottom-Right Layout & Steps Workflow
  Widget _buildSlide1(BuildContext context, Size size, Color activeColor) {
    // Local relative scroll offset for page 1
    final double localOffset = scrollOffset - 1.0;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),

          // Image at the Top-Left with opposite 3D tilt and parallax
          SizedBox(
            height: size.height * 0.28,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -16 + (localOffset * 45),
                  top: 0,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-0.06 - localOffset * 0.15)
                      ..rotateX(localOffset * 0.1)
                      ..rotateZ(0.06 + localOffset * 0.04),
                    alignment: Alignment.center,
                    child: _buildImage(size, activeColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Headline
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1.15,
              letterSpacing: -1.2,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // Glassmorphic Card containing Steps Flow
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          height: 1.6,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Customizer workflow step row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStepItem('1. Chọn sản phẩm', activeColor),
                          const Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.black26),
                          _buildStepItem('2. Phối màu & Logo', activeColor),
                          const Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.black26),
                          _buildStepItem('3. Đặt may riêng', activeColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // SLIDE 2: Cinematic Centered Layout + Checklist of Benefits
  Widget _buildSlide2(BuildContext context, Size size, Color activeColor) {
    final double localOffset = scrollOffset - 2.0;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // Centered Headline
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1.15,
              letterSpacing: -1.2,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),

          // Glassmorphic card containing checklists
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          height: 1.6,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Checklist of benefits
                      _buildBenefitItem('Theo dõi hành trình đơn hàng thời gian thực (Real-time)'),
                      const SizedBox(height: 8),
                      _buildBenefitItem('Quản lý sổ địa chỉ giao nhận hàng nhanh chóng'),
                      const SizedBox(height: 8),
                      _buildBenefitItem('Hỗ trợ chat trực tuyến Live Chat 24/7 trực tiếp'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Centered 3D Image with subtle parallax scaling
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: -20 + (localOffset * 30),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(0.06 - localOffset * 0.12)
                      ..rotateY(localOffset * 0.08),
                    alignment: Alignment.center,
                    child: _buildImage(size, activeColor, isWide: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shared widget to render high-contrast mockup images with radial border
  Widget _buildImage(Size size, Color activeColor, {bool isWide = false}) {
    return Container(
      width: size.width * (isWide ? 0.8 : 0.72),
      height: size.height * 0.28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            activeColor.withValues(alpha: 0.05),
            BlendMode.colorBurn,
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFFF1F5F9),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFE2E8F0),
                child: const Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Shared components for styling slide details
  Widget _buildTechChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStepItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 16,
          color: Color(0xFF10B981), // Emerald Green
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.4,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
