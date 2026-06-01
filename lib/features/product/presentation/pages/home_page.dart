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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          } else if (state is ProductLoaded) {
            return _buildContent(context, state.products);
          } else if (state is ProductError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          height: 1,
        ),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Transform(
          transform: Matrix4.skewX(-0.15),
          child: Text(
            'Sport Pro',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
              letterSpacing: -1.2,
            ),
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        const NotificationBellIcon(),
        BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            int cartCount = 0;
            if (cartState is CartLoaded) {
              cartCount = cartState.totalItems;
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => context.goNamed(AppRoutes.cart),
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        BlocBuilder<ChatCubit, ChatState>(
          builder: (context, chatState) {
            final unreadCount = context.read<ChatCubit>().totalUnreadMessages;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => context.goNamed(AppRoutes.chatList),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent, // Safety Orange
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<ProductEntity> products) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero Section
          _buildHeroSection(context),

          // 2. Categories Snap Horizontal Scroll Section
          _buildCategoriesSection(context),

          // 3. Featured Products Grid Section
          _buildFeaturedProducts(context, products),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Container(
        height: 360,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dark Background Image
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDfNUm_0FHTlwMSO97i6w_ybGmHoVLk34xXuVJ138ODeFyymicdmeoElKE4Dw81L669C3EY5e3nBvEaHO2ATTV4XRAbGpQa9oJk7YDslOWIh5l3Cet1fbGGmoW6374uazzBD6RKNWmaZ_9VmgeDnFssIy9zvvN1_YLcGOe8LXyWG63NcbpAyus8mOU5IT6-HZBiyV8msC80n3Zzr4JIoddV8XatdZ_RGD-GClcpI9keO_oHzq8zRr6z6giBAQ6BwerYe3LWlHOp31c',
              fit: BoxFit.cover,
            ),
            // Black gradient overlay for readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black87,
                    Colors.black38,
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Content Overlay
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform(
                    transform: Matrix4.skewX(-0.15),
                    child: Text(
                      'BỨT PHÁ GIỚI HẠN',
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trang bị tối tân cho những vận động viên không ngừng vươn lên.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.goNamed(AppRoutes.productList),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent, // Safety Orange
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'MUA SẮM NGAY',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed(AppRoutes.productList),
                  child: Text(
                    'XEM TẤT CẢ',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to product list prefiltering by category name
                    context.goNamed(AppRoutes.productList);
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Category Cover Image
                        Image.network(
                          cat['image']!,
                          fit: BoxFit.cover,
                        ),
                        // Dark Overlay
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black87,
                                Colors.black12,
                              ],
                            ),
                          ),
                        ),
                        // Label text
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            cat['title']!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
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
    // Limit to first 4 products for featured listing
    final featuredList = products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sản phẩm nổi bật',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.51,
            ),
            itemCount: featuredList.length,
            itemBuilder: (context, index) {
              final product = featuredList[index];
              return _buildProductCard(context, product, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product, int index) {
    // Alternate badges mockups to perfectly mirror Stitch mockup V2
    String? badgeLabel;
    if (index == 0) badgeLabel = 'NEW';
    if (index == 1) badgeLabel = '-15%';

    final categoryLabel = product.categoryId == 'cat-training'
        ? 'TRANG PHỤC'
        : 'GIÀY CHẠY BỘ';

    return GestureDetector(
      onTap: () {
        context.goNamed(
          AppRoutes.productDetail,
          pathParameters: {'productId': product.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Hero Image area (4:5 Ratio)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFF3F3F8),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Optional Promo/New overlay Badge
                  if (badgeLabel != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent, // Safety Orange
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabel,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavTab(
              context: context,
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: true,
              onTap: () {},
            ),
            _buildNavTab(
              context: context,
              icon: Icons.directions_run_rounded,
              label: 'Shop',
              isActive: false,
              onTap: () => context.goNamed(AppRoutes.productList),
            ),
            _buildNavTab(
              context: context,
              icon: Icons.receipt_long_rounded,
              label: 'Orders',
              isActive: false,
              onTap: () => context.goNamed(AppRoutes.orderList),
            ),
            _buildNavTab(
              context: context,
              icon: Icons.person_rounded,
              label: 'Profile',
              isActive: false,
              onTap: () => context.goNamed(AppRoutes.profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi khi tải trang chủ.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
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

  String _formatPrice(double price) {
    final formatStr = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < formatStr.length; i++) {
      buffer.write(formatStr[i]);
      if ((formatStr.length - 1 - i) % 3 == 0 && i != formatStr.length - 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}
