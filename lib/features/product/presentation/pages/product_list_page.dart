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

part 'product_list_content.dart';
part 'product_list_error_state.dart';
part 'product_list_sort_sheet.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _selectedCategory = 'Tất cả';
  String _selectedSort = 'Không sắp xếp';

  final List<String> _categories = [
    'Tất cả',
    'Giày chạy bộ',
    'Nam',
    'Size 42',
    'Quần áo',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductBloc>().add(const ProductListRequested());
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _selectSort(String sort) {
    setState(() {
      _selectedSort = sort;
    });
  }

  @override
  Widget build(BuildContext context) {
    NavigationHistory.pushTab(AppRoutes.productList);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          if (context.canPop()) {
            context.pop();
          } else {
            final prevTab = NavigationHistory.popTab();
            if (prevTab != null) {
              context.goNamed(prevTab);
            }
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
                  final products = List<ProductEntity>.from(state.products);

                  // Category filtering
                  final filteredProducts = products.where((product) {
                    if (_selectedCategory == 'Tất cả') return true;
                    if (_selectedCategory == 'Giày chạy bộ') {
                      return product.categoryId == 'cat-running';
                    }
                    if (_selectedCategory == 'Quần áo') {
                      return product.categoryId == 'cat-clothing';
                    }
                    return true;
                  }).toList();

                  // Sort price
                  if (_selectedSort == 'Giá tăng dần') {
                    filteredProducts.sort((a, b) => a.price.compareTo(b.price));
                  } else if (_selectedSort == 'Giá giảm dần') {
                    filteredProducts.sort((a, b) => b.price.compareTo(a.price));
                  }

                  return _buildScrollView(statusBarHeight, filteredProducts);
                } else if (state is ProductError) {
                  return _buildErrorState(state.message);
                }
                return const SizedBox.shrink();
              },
            ),

            // 2. Reusable Glassmorphic Top App Bar (showing back button)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassAppBar(
                showBackButton: true,
                customTitle: 'Sport Pro',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GlassBottomBar(currentTab: 'shop'),
    );
  }
}
