import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_state.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/shared/product_tactile_card.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/home/product_home_hero_section.dart';

class ProductHomeContent extends StatelessWidget {
  final List<ProductEntity> products;
  final double statusBarHeight;

  const ProductHomeContent({
    super.key,
    required this.products,
    required this.statusBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(0, statusBarHeight + 92, 0, 120),
      children: [
        const ProductHomeHeroSection(),
        const _HomeCategorySection(),
        _FeaturedProductsSection(products: products),
      ],
    );
  }
}

class _HomeCategorySection extends StatelessWidget {
  const _HomeCategorySection();

  static const double _stripHeight = 120;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        // Hide the whole section on error so the rest of the home page
        // (hero + featured products) still renders normally.
        if (state is CategoryError) return const SizedBox.shrink();

        final categories = state is CategoryLoaded
            ? state.categories.where((c) => c.isActive).toList()
            : const <CategoryEntity>[];
        final isLoading = state is CategoryLoading || state is CategoryInitial;

        if (!isLoading && categories.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HomeSectionHeader(),
              const SizedBox(height: AppSizes.fontLg),
              SizedBox(
                height: _stripHeight,
                child: isLoading
                    ? const _HomeCategoryStripPlaceholder()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingLg),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSizes.radiusLg),
                        itemBuilder: (context, index) => _HomeCategoryCard(
                          category: categories[index],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeCategoryStripPlaceholder extends StatelessWidget {
  const _HomeCategoryStripPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
      itemCount: 4,
      separatorBuilder: (context, index) =>
          const SizedBox(width: AppSizes.radiusLg),
      itemBuilder: (context, index) => Container(
        width: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppStrings.productHomeCategoriesTitle,
            style: GoogleFonts.lexend(
              fontSize: AppSizes.fontXxl,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          GestureDetector(
            onTap: () => context.goNamed(AppRoutes.productList),
            child: Text(
              AppStrings.productHomeViewAll,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategoryCard extends StatelessWidget {
  final CategoryEntity category;

  const _HomeCategoryCard({required this.category});

  void _openCategory(BuildContext context) {
    context.goNamed(
      AppRoutes.productList,
      extra: {
        'categoryId': category.id,
        'categoryName': category.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: () => _openCategory(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _HomeCategoryImageFallback(),
              )
            else
              const _HomeCategoryImageFallback(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.7),
                    Colors.black12,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: AppSizes.radiusLg,
              left: AppSizes.radiusLg,
              right: AppSizes.radiusLg,
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCategoryImageFallback extends StatelessWidget {
  const _HomeCategoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Icon(
        Icons.category_outlined,
        color: AppColors.primary.withValues(alpha: 0.6),
        size: AppSizes.fontXxl,
      ),
    );
  }
}

class _FeaturedProductsSection extends StatelessWidget {
  final List<ProductEntity> products;

  const _FeaturedProductsSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.productHomeFeaturedTitle,
            style: GoogleFonts.lexend(
              fontSize: AppSizes.fontXxl,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSizes.fontXxl),
          if (products.isEmpty)
            const _FeaturedProductsEmptyState()
          else
            _FeaturedProductRows(products: products.take(4).toList()),
        ],
      ),
    );
  }
}

class _FeaturedProductRows extends StatelessWidget {
  final List<ProductEntity> products;

  const _FeaturedProductRows({required this.products});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < products.length; index += 2) {
      final firstProduct = products[index];
      final secondProduct =
          index + 1 < products.length ? products[index + 1] : null;
      rows.add(_FeaturedProductRow(
        firstProduct: firstProduct,
        secondProduct: secondProduct,
      ));
      if (index + 2 < products.length) {
        rows.add(AppSizes.spacingMd);
      }
    }
    return Column(children: rows);
  }
}

class _FeaturedProductRow extends StatelessWidget {
  final ProductEntity firstProduct;
  final ProductEntity? secondProduct;

  const _FeaturedProductRow({
    required this.firstProduct,
    required this.secondProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ProductTactileCard(product: firstProduct)),
        AppSizes.spacingMd,
        Expanded(
          child: secondProduct != null
              ? ProductTactileCard(product: secondProduct!)
              : SizedBox(),
        ),
      ],
    );
  }
}

class _FeaturedProductsEmptyState extends StatelessWidget {
  const _FeaturedProductsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          AppStrings.productHomeFeaturedEmpty,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontLg,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
