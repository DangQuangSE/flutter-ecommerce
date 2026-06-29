import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/core/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/core/widgets/product_tactile_card.dart';

import 'package:flutter_ecommerce/app/router/navigation_history.dart';

part 'home_content.dart';
part 'home_error_state.dart';
part 'home_hero_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> _categories = [
    {
      'title': 'Giày Chạy',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuATtvA9dpwpeZk45mc9bEBjeatBPszQFU0FYFVfZbFEUJ7HRwIHMRwHzAy55ziexRfDl324LqvYrMaboFgsiysd-bPLAW1MvDpMR0arf8p03vEseyN9zgQ53g8yYVuhoqBu7EDrKqcqYwegqNKBTHitNy5_cvQ4c8xL9TE2Q0r9eER1Zk0qxIVhAhNgV1_zzUT5JpdYv0ylO3P5F0jK5tF2r7MP1DrHGpsqZp_Cox8dCPrFXgbgBuprKEoar3JX7cS8IEKaBkXojMA'
    },
    {
      'title': 'Trang Phục',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB717wQyS9AeENXDPoVWHtgsZS4I3An4etSvXGYlLQlv7KUi9-JhnR3VvdBFzpd35CYGm2yqeQADcqbXIcx_bZuMkNcb4ftRm6cv-d4zNMRKi2puai365v2sDoJTneRoT4LtNAufZpClH6mTsNQ3BOSGKcKAjxSl82R8MwKU9vlYATmJq8p_2iUVerLZLjK8CYZwIDbK_ZcBtBlFWMqvPJikuNwPySWj9CK3N5jcGysAjyUsPR5JZ-okI-Na1ctcuGdiuvpt5QT1xk'
    },
    {
      'title': 'Phụ Kiện',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAqN3fOwg4iAv0K-OFpyptPcv5kI3Iv1cGfh6c3Rzx9NckeONlTagtHJF5OHW9T3H5tYeLq4zwHCRDAQhx2GpRPpSxZ5oO-XPyY1BkNZcw1H2M5XLooFtSRUmwQOFw4AzhzWgn5dege0eP0pSyXVJtWAjWYa1EnShBUT4WiPy4EhfA7rn4CpsyurmFWbHsB948-EkN9cMIgdSCT67_JVLPqnasX_UxQbBvmlAj2dLE8V1OHBXFEmFOKqyw_JDoxodxB5EdVGZy2jVI'
    },
    {
      'title': 'Dụng Cụ',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCbXbEZkYN1PdBUeNwKfJKjjlBmd9AR-t3-OPPhAkxmS-Mgz39vRedxqhOq56wfXTGDPZbfO8HoGyJO5Qe5y34MjqP8pNlntjOGCbOz4huinr3D1M3fBM9zdSaNreqm8JVPI7GaG5s7z6Ol4nZNEt9w_BS5mLwpzD_KieykR9Jljkmk90gdb-zkjv55_oik-Ls1z_O6DBp-rgO6h81liKqVsjE71gmEQjfTU28A42cFidqRRk_MuQaKDdET5xZBolS-dRy434N85hg'
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
        onPopInvokedWithResult: (bool didPop, Object? result) {
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                } else if (state is ProductLoaded) {
                  return _buildContent(
                      context, state.products, statusBarHeight);
                } else if (state is ProductError) {
                  return _buildErrorState(state.message);
                }
                return const SizedBox.shrink();
              },
            ),

            // 2. Reusable Glassmorphic Top App Bar
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassAppBar(
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
}
