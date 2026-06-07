import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/notification/presentation/widgets/notification_bell_icon.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/core/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/core/widgets/product_tactile_card.dart';

import 'package:flutter_ecommerce/app/router/navigation_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> _categories = [
    {
      'title': 'Giày Chạy',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuATtvA9dpwpeZk45mc9bEBjeatBPszQFU0FYFVfZbFEUJ7HRwIHMRwHzAy55ziexRfDl324LqvYrMaboFgsiysd-bPLAW1MvDpMR0arf8p03vEseyN9zgQ53g8yYVuhoqBu7EDrKqcqYwegqNKBTHitNy5_cvQ4c8xL9TE2Q0r9eER1Zk0qxIVhAhNgV1_zzUT5JpdYv0ylO3P5F0jK5tF2r7MP1DrHGpsqZp_Cox8dCPrFXgbgBuprKEoar3JX7cS8IEKaBkXojMA'
    },
    {
      'title': 'Trang Phục',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB717wQyS9AeENXDPoVWHtgsZS4I3An4etSvXGYlLQlv7KUi9-JhnR3VvdBFzpd35CYGm2yqeQADcqbXIcx_bZuMkNcb4ftRm6cv-d4zNMRKi2puai365v2sDoJTneRoT4LtNAufZpClH6mTsNQ3BOSGKcKAjxSl82R8MwKU9vlYATmJq8p_2iUVerLZLjK8CYZwIDbK_ZcBtBlFWMqvPJikuNwPySWj9CK3N5jcGysAjyUsPR5JZ-okI-Na1ctcuGdiuvpt5QT1xk'
    },
    {
      'title': 'Phụ Kiện',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAqN3fOwg4iAv0K-OFpyptPcv5kI3Iv1cGfh6c3Rzx9NckeONlTagtHJF5OHW9T3H5tYeLq4zwHCRDAQhx2GpRPpSxZ5oO-XPyY1BkNZcw1H2M5XLooFtSRUmwQOFw4AzhzWgn5dege0eP0pSyXVJtWAjWYa1EnShBUT4WiPy4EhfA7rn4CpsyurmFWbHsB948-EkN9cMIgdSCT67_JVLPqnasX_UxQbBvmlAj2dLE8V1OHBXFEmFOKqyw_JDoxodxB5EdVGZy2jVI'
    },
    {
      'title': 'Dụng Cụ',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCbXbEZkYN1PdBUeNwKfJKjjlBmd9AR-t3-OPPhAkxmS-Mgz39vRedxqhOq56wfXTGDPZbfO8HoGyJO5Qe5y34MjqP8pNlntjOGCbOz4huinr3D1M3fBM9zdSaNreqm8JVPI7GaG5s7z6Ol4nZNEt9w_BS5mLwpzD_KieykR9Jljkmk90gdb-zkjv55_oik-Ls1z_O6DBp-rgO6h81liKqVsjE71gmEQjfTU28A42cFidqRRk_MuQaKDdET5xZBolS-dRy434N85hg'
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductBloc>().add(const ProductListRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    NavigationHistory.pushTab(AppRoutes.home, replace: true);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) return;
          final prevTab = NavigationHistory.popTab();
          if (prevTab != null) {
            context.goNamed(prevTab);
          }
        },
        child: Stack(
          children: [
            // 1. Core scrollable contents
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                } else if (state is ProductLoaded) {
                  return _buildContent(context, state.products, statusBarHeight);
                } else if (state is ProductError) {
                  return _buildErrorState(state.message);
                }
                return const SizedBox.shrink();
              },
            ),

            // 2. Reusable Glassmorphic Top App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const GlassAppBar(
                showBackButton: false,
                customTitle: 'Sport Pro',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GlassBottomBar(currentTab: 'home'),
    );
  }

  Widget _buildContent(BuildContext context, List<ProductEntity> products, double statusBarHeight) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(0, statusBarHeight + 92, 0, 120),
      children: [
        // 1. Hero Section (Nested Double-Bezel & Button-in-Button CTA)
        _buildHeroSection(context),

        // 2. Categories Snap Horizontal Scroll Section (Glassmorphic)
        _buildCategoriesSection(context),

        // 3. Featured Products Grid Section (Asymmetric Bento)
        _buildFeaturedProducts(context, products),
      ],
    );
  }

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
              color: Colors.black.withOpacity(0.02),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
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
                        color: Colors.white.withOpacity(0.75),
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

  Widget _buildTactileCTA(BuildContext context, {required String label, required VoidCallback onPressed}) {
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

  Widget _buildCategoriesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Danh mục',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed(AppRoutes.productList),
                  child: Text(
                    'XEM TẤT CẢ',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          
          // Category horizontal gallery
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () => context.goNamed(AppRoutes.productList),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Image.network(
                          cat['image']!,
                          fit: BoxFit.cover,
                        ),
                        // Soft overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.black12,
                              ],
                            ),
                          ),
                        ),
                        // Title text
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            cat['title']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context, List<ProductEntity> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sản phẩm nổi bật',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Không có sản phẩm nổi bật nào.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final featuredList = products.take(4).toList();
    final List<Widget> rows = [];
    
    for (int i = 0; i < featuredList.length; i += 2) {
      final item1 = featuredList[i];
      final item2 = (i + 1 < featuredList.length) ? featuredList[i + 1] : null;
      
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProductTactileCard(
                product: item1,
                badge: i == 0 ? 'NEW' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: item2 != null
                  ? ProductTactileCard(
                      product: item2,
                      badge: i == 0 ? '-15%' : null,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
      
      if (i + 2 < featuredList.length) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sản phẩm nổi bật',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),
          ...rows,
        ],
      ),
    );
  }

  // Shared Navigation component hooks are utilized dynamically

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi khi tải trang chủ.',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(const ProductListRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// Shared ProductTactileCard handles individual card details and tap physics dynamically
