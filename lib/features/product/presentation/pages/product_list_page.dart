import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/router/navigation_history.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/app/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_content.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_error_view.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_filter_option.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_sort_sheet.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  ProductListCategoryOption _selectedCategory = ProductListCategoryOption.all;
  ProductListSortOption _selectedSort = ProductListSortOption.none;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductBloc>().add(const ProductListRequested());
    });
  }

  void _selectCategory(ProductListCategoryOption category) {
    setState(() => _selectedCategory = category);
  }

  Future<void> _openSortSheet() async {
    final sort = await showProductListSortSheet(
      context: context,
      selectedSort: _selectedSort,
    );
    if (!mounted || sort == null) return;
    setState(() => _selectedSort = sort);
  }

  List<ProductEntity> _buildVisibleProducts(List<ProductEntity> products) {
    final filteredProducts = products.where((product) {
      final categoryId = _selectedCategory.categoryId;
      if (categoryId == null) return true;
      return product.categoryId == categoryId;
    }).toList();

    switch (_selectedSort) {
      case ProductListSortOption.priceAscending:
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      case ProductListSortOption.priceDescending:
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      case ProductListSortOption.none:
        break;
    }

    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    NavigationHistory.pushTab(AppRoutes.productList);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (context.canPop()) {
            context.pop();
            return;
          }
          final prevTab = NavigationHistory.popTab();
          if (prevTab != null) {
            context.goNamed(prevTab);
          }
        },
        child: Stack(
          children: [
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                return switch (state) {
                  ProductLoading() => const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ProductLoaded(:final products) => ProductListContent(
                      statusBarHeight: statusBarHeight,
                      products: _buildVisibleProducts(products),
                      selectedCategory: _selectedCategory,
                      categories: ProductListCategoryOption.defaults,
                      selectedSort: _selectedSort,
                      onCategorySelected: _selectCategory,
                      onSortTap: _openSortSheet,
                    ),
                  ProductError(:final message) =>
                    ProductListErrorView(message: message),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassAppBar(
                showBackButton: true,
                customTitle: AppStrings.brandName,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GlassBottomBar(currentTab: 'shop'),
    );
  }
}
