import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_cubit.dart';
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
  static const _loadMoreThreshold = 0.8;
  static const _bottomContentPadding = 100.0;
  static const _glassAppBarContentHeight = 48.0;

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
    if (current < maxExtent * _loadMoreThreshold) return;

    final bloc = context.read<ProductCatalogBloc>();
    if (bloc.state is ProductCatalogLoaded) {
      bloc.add(ProductCatalogLoadMore());
    }
  }

  void _openFilter(ProductCatalogLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProductCatalogBloc>()),
          BlocProvider.value(value: context.read<ProductFilterOptionsCubit>()),
        ],
        child: ProductFilterBottomSheet(appliedState: state),
      ),
    );
  }

  void _clearAllFilters() {
    context.read<ProductCatalogBloc>().add(
          ProductCatalogFilterChanged(clearAll: true, silent: true),
        );
  }

  Future<ProductCatalogState> _refreshCatalog() {
    final bloc = context.read<ProductCatalogBloc>();
    bloc.add(ProductCatalogRefreshed());
    return bloc.stream.firstWhere(
      (state) =>
          (state is ProductCatalogLoaded && !state.isLoadingMore) ||
          state is ProductCatalogError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = statusBarHeight + _glassAppBarContentHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: const GlassBottomBar(currentTab: 'shop'),
      body: Stack(
        children: [
          BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
            builder: (context, state) {
              if (state is ProductCatalogLoading) {
                return _CatalogLoadingView(appBarHeight: appBarHeight);
              }

              if (state is ProductCatalogError) {
                return _CatalogErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<ProductCatalogBloc>()
                      .add(ProductCatalogFetch()),
                );
              }

              final loaded = state is ProductCatalogLoaded ? state : null;

              return RefreshIndicator(
                onRefresh: _refreshCatalog,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.paddingMd,
                        appBarHeight + AppSizes.paddingMd,
                        AppSizes.paddingMd,
                        0,
                      ),
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
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.paddingMd,
                          AppSizes.paddingSm,
                          AppSizes.paddingMd,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: ActiveFilterChips(
                            state: loaded,
                            onClearAll: _clearAllFilters,
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.paddingMd,
                        AppSizes.paddingMd,
                        AppSizes.paddingMd,
                        _bottomContentPadding,
                      ),
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassAppBar(),
          ),
        ],
      ),
    );
  }
}

class _CatalogLoadingView extends StatelessWidget {
  final double appBarHeight;

  const _CatalogLoadingView({required this.appBarHeight});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingMd,
        appBarHeight + AppSizes.paddingMd,
        AppSizes.paddingMd,
        _ProductCatalogPageState._bottomContentPadding,
      ),
      child: const ProductSkeletonGrid(),
    );
  }
}

class _CatalogErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CatalogErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: AppSizes.iconXl,
            color: AppColors.error,
          ),
          AppSizes.spacingMd,
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          AppSizes.spacingMd,
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}
