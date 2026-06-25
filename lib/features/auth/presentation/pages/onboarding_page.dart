import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_ambient_background.dart';
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

  final List<Map<String, String>> _slides = [
    {
      'title': 'Bứt phá\ngiới hạn.',
      'description':
          'Trải nghiệm dòng sản phẩm thể thao cao cấp được thiết kế chuyên biệt để nâng tầm hiệu suất luyện tập của bạn hàng ngày.',
      'imageUrl':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=600',
    },
    {
      'title': 'Tùy biến\nđộc bản.',
      'description':
          'Sáng tạo phong cách cá nhân với công cụ Customizer 3D. Tự tay thiết kế và phối màu trang phục thi đấu của riêng bạn.',
      'imageUrl':
          'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?q=80&w=600',
    },
    {
      'title': 'Bắt đầu\nhành trình.',
      'description':
          'Tham gia cộng đồng Sport Pro ngay hôm nay để nhận những đặc quyền ưu đãi dành riêng cho thành viên và sẵn sàng bứt tốc.',
      'imageUrl':
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=600',
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
    // Save onboarding completion state to local storage
    await sl<LocalStorage>().setBool('has_seen_onboarding', value: true);
    if (mounted) {
      context.goNamed(AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.32, 0.72, 0, 1.0), // High-end spring physical curve
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentIndex == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Premium Ambient Blurred Texture Background
          const AuthAmbientBackground(),

          // PageView Slider containing asymmetric slides
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
              // Slide offset calculated relative to this page's index
              final slideOffset = _scrollOffset - index;
              return OnboardingSlide(
                title: slide['title']!,
                description: slide['description']!,
                imageUrl: slide['imageUrl']!,
                scrollOffset: slideOffset,
              );
            },
          ),

          // Floating Controls Bar (Bottom)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Skip / Back Navigation Button with scale physics
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Dynamic Slanted Pill Indicator
                OnboardingIndicator(
                  count: _slides.length,
                  currentIndex: _currentIndex,
                ),

                // 3. Nested CTA "Island" Button with custom spring scale transitions
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
                        borderRadius: BorderRadius.circular(100), // Pill rounded
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
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Nested trailing icon circle
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
