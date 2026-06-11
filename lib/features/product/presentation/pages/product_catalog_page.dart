import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/active_filter_chips.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/catalog_toolbar.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_bottom_sheet.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_grid.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_skeleton_grid.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (current >= maxExtent * 0.8) {
      final bloc = context.read<ProductCatalogBloc>();
      if (bloc.state is ProductCatalogLoaded) {
        bloc.add(ProductCatalogLoadMore());
      }
    }
  }

  void _openFilter(ProductCatalogLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFilterBottomSheet(appliedState: state),
    );
  }

  void _clearAllFilters() {
    context.read<ProductCatalogBloc>().add(
          ProductCatalogFilterChanged(clearAll: true, silent: true),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sản phẩm',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
        builder: (context, state) {
          if (state is ProductCatalogLoading) {
            return const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ProductSkeletonGrid(),
            );
          }

          if (state is ProductCatalogError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ProductCatalogBloc>()
                        .add(ProductCatalogFetch()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final loaded =
              state is ProductCatalogLoaded ? state : null;

          return RefreshIndicator(
            onRefresh: () {
              final bloc = context.read<ProductCatalogBloc>();
              bloc.add(ProductCatalogRefreshed());
              return bloc.stream.firstWhere(
                (s) =>
                    (s is ProductCatalogLoaded && !s.isLoadingMore) ||
                    s is ProductCatalogError,
              );
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: CatalogToolbar(
                      hasActiveFilter: loaded?.hasActiveFilter ?? false,
                      onFilterTap: () {
                        if (loaded != null) _openFilter(loaded);
                      },
                    ),
                  ),
                ),
                if (loaded != null && loaded.hasActiveFilter)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: ActiveFilterChips(
                        state: loaded,
                        onClearAll: _clearAllFilters,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: ProductGrid(
                      products: loaded?.products ?? [],
                      isLoadingMore: loaded?.isLoadingMore ?? false,
                      onClearFilters: loaded?.hasActiveFilter == true
                          ? _clearAllFilters
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
