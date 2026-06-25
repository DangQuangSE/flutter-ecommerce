import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
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
  late final AnimationController _primaryButtonController;
  late final AnimationController _secondaryButtonController;

  int _currentIndex = 0;
  double _scrollOffset = 0.0;

  // Introductions focused on the platform/web capabilities with Unsplash 3D graphics
  final List<Map<String, String>> _slides = [
    {
      'title': 'Mua sắm trực tuyến',
      'description':
          'Trải nghiệm website mua sắm hiện đại. Dễ dàng duyệt catalog, tìm kiếm sản phẩm với bộ lọc thông minh và thanh toán trực tuyến bảo mật qua cổng VNPay.',
      'imageUrl':
          'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?q=80&w=600',
    },
    {
      'title': 'Tự tay thiết kế',
      'description':
          'Đột phá với trình customizer trực quan. Tự do tùy biến kiểu dáng, phối màu sắc và thiết kế logo trực tiếp trên giao diện 3D thời gian thực.',
      'imageUrl':
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?q=80&w=600',
    },
    {
      'title': 'Quản lý dễ dàng',
      'description':
          'Kiểm soát mọi thông tin cá nhân. Theo dõi hành trình đơn hàng trực tiếp, lưu sổ địa chỉ giao nhận tiện lợi và trò chuyện tư vấn tức thì qua Live Chat.',
      'imageUrl':
          'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?q=80&w=600',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onScroll);

    // Spring scale physics controllers
    _primaryButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );

    _secondaryButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _primaryButtonController.dispose();
    _secondaryButtonController.dispose();
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

  Future<void> _completeOnboardingWithLogin() async {
    // Save onboarding completion state and route to login
    await sl<LocalStorage>().setBool('has_seen_onboarding', value: true);
    if (mounted) {
      context.goNamed(AppRoutes.login);
    }
  }

  Future<void> _completeOnboardingWithRegister() async {
    // Save onboarding completion state and route to register
    await sl<LocalStorage>().setBool('has_seen_onboarding', value: true);
    if (mounted) {
      context.goNamed(AppRoutes.register);
    }
  }

  void _primaryAction() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: const Cubic(0.32, 0.72, 0, 1.0), // spring curve
      );
    } else {
      _completeOnboardingWithRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentIndex == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep dark gradient background with central glow
          OnboardingAmbientBackground(scrollOffset: _scrollOffset),

          // 2. Horizontal slides Viewport
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

          // 3. Top-Right Skip Text Button (fades on last page)
          Positioned(
            top: 48,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isLastPage ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: isLastPage,
                child: TextButton(
                  onPressed: _completeOnboardingWithLogin,
                  child: Text(
                    'Bỏ qua',
                    style: GoogleFonts.lexend(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Bottom Controls Overlay (Indicators + Stacked Pill Buttons)
          Positioned(
            bottom: size.height * 0.05,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A. Stretched indicators
                OnboardingIndicator(
                  count: _slides.length,
                  scrollOffset: _scrollOffset,
                ),
                const SizedBox(height: 36),

                // B. Primary Button (Solid White)
                GestureDetector(
                  onTapDown: (_) => _primaryButtonController.reverse(),
                  onTapUp: (_) => _primaryButtonController.forward(),
                  onTapCancel: () => _primaryButtonController.forward(),
                  onTap: _primaryAction,
                  child: ScaleTransition(
                    scale: _primaryButtonController,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          isLastPage ? 'ĐĂNG KÝ' : 'TIẾP TỤC',
                          style: GoogleFonts.lexend(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // C. Secondary Button (Outlined Transparent)
                GestureDetector(
                  onTapDown: (_) => _secondaryButtonController.reverse(),
                  onTapUp: (_) => _secondaryButtonController.forward(),
                  onTapCancel: () => _secondaryButtonController.forward(),
                  onTap: _completeOnboardingWithLogin,
                  child: ScaleTransition(
                    scale: _secondaryButtonController,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'ĐĂNG NHẬP',
                          style: GoogleFonts.lexend(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
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
