part of 'home_page.dart';

extension _HomeHeroSection on _HomePageState {
  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      // Outer Bezel Shell (Concentric outer frame)
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Inner Core Card
        child: Container(
          height: 380,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDfNUm_0FHTlwMSO97i6w_ybGmHoVLk34xXuVJ138ODeFyymicdmeoElKE4Dw81L669C3EY5e3nBvEaHO2ATTV4XRAbGpQa9oJk7YDslOWIh5l3Cet1fbGGmoW6374uazzBD6RKNWmaZ_9VmgeDnFssIy9zvvN1_YLcGOe8LXyWG63NcbpAyus8mOU5IT6-HZBiyV8msC80n3Zzr4JIoddV8XatdZ_RGD-GClcpI9keO_oHzq8zRr6z6giBAQ6BwerYe3LWlHOp31c',
                fit: BoxFit.cover,
              ),
              // Linear ambient darkening overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.black26,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Content panel
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow label
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        'DÒNG SẢN PHẨM MỚI NHẤT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Transform(
                      transform: Matrix4.skewX(-0.12),
                      child: Text(
                        'BỨT PHÁ GIỚI HẠN',
                        style: GoogleFonts.lexend(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Trang bị đỉnh cao cho những vận động viên không ngừng vươn lên và chinh phục đỉnh cao mới.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Button-in-Button primary CTA
                    _buildTactileCTA(
                      context,
                      label: 'MUA SẮM NGAY',
                      onPressed: () => context.goNamed(AppRoutes.productList),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTactileCTA(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 150),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.fromLTRB(20, 6, 6, 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(0, 0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 14),
                // "Button-in-Button" circular trailing badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
