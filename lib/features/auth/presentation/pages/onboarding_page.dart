import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/onboarding_ambient_background.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/onboarding_slide.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/onboarding_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _buttonScaleController;
  late final Animation<double> _buttonScaleAnimation;

  int _currentIndex = 0;
  double _scrollOffset = 0.0;

  // Introductions focused on the platform/web capabilities
  final List<Map<String, String>> _slides = [
    {
      'title': 'Mua sắm\ntrực tuyến.',
      'description':
          'Trải nghiệm website mua sắm hiện đại. Dễ dàng duyệt catalog, tìm kiếm sản phẩm với bộ lọc thông minh và thanh toán trực tuyến bảo mật qua cổng VNPay.',
      'imageUrl':
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=600',
    },
    {
      'title': 'Tự tay\nthiết kế.',
      'description':
          'Đột phá với trình customizer trực quan. Tự do tùy biến kiểu dáng, phối màu sắc và thiết kế logo trực tiếp trên giao diện 3D thời gian thực.',
      'imageUrl':
          'https://images.unsplash.com/photo-1531403009284-440f080d1e12?q=80&w=600',
    },
    {
      'title': 'Quản lý\ndễ dàng.',
      'description':
          'Kiểm soát mọi thông tin cá nhân. Theo dõi hành trình đơn hàng trực tiếp, lưu sổ địa chỉ giao nhận tiện lợi và trò chuyện tư vấn tức thì qua Live Chat.',
      'imageUrl':
          'https://images.unsplash.com/photo-1551434678-e076c223a692?q=80&w=600',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onScroll);

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _buttonScaleAnimation = _buttonScaleController;
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pageController.hasClients) {
      setState(() {
        _scrollOffset = _pageController.offset /
            MediaQuery.of(context).size.width;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    // Persist seen status in SharedPreferences (local storage)
    await sl<LocalStorage>().setBool('has_seen_onboarding', value: true);
    if (mounted) {
      context.goNamed(AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: const Cubic(0.32, 0.72, 0, 1.0), // Spring feel easing curve
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic mesh color-interpolated background
          OnboardingAmbientBackground(scrollOffset: _scrollOffset),

          // Slide Viewport
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              final slideOffset = _scrollOffset - index;
              return OnboardingSlide(
                index: index,
                title: slide['title']!,
                description: slide['description']!,
                imageUrl: slide['imageUrl']!,
                scrollOffset: slideOffset,
              );
            },
          ),

          // Lower control action bar
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Skip button (faded out on last page)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLastPage ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: isLastPage,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: Text(
                        'BỎ QUA',
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Liquid continuous slanted indicator
                OnboardingIndicator(
                  count: _slides.length,
                  scrollOffset: _scrollOffset,
                ),

                // 3. Nested CTA Button with scale physics
                GestureDetector(
                  onTapDown: (_) => _buttonScaleController.reverse(),
                  onTapUp: (_) => _buttonScaleController.forward(),
                  onTapCancel: () => _buttonScaleController.forward(),
                  onTap: _nextPage,
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastPage ? 'BẮT ĐẦU' : 'TIẾP TỤC',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Circle nested arrow
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white24,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
