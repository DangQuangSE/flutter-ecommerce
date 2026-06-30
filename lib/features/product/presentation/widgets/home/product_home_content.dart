import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/product_tactile_card.dart';
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
  static const _categories = [
    _HomeCategory(
      title: AppStrings.productHomeCategoryRunning,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuATtvA9dpwpeZk45mc9bEBjeatBPszQFU0FYFVfZbFEUJ7HRwIHMRwHzAy55ziexRfDl324LqvYrMaboFgsiysd-bPLAW1MvDpMR0arf8p03vEseyN9zgQ53g8yYVuhoqBu7EDrKqcqYwegqNKBTHitNy5_cvQ4c8xL9TE2Q0r9eER1Zk0qxIVhAhNgV1_zzUT5JpdYv0ylO3P5F0jK5tF2r7MP1DrHGpsqZp_Cox8dCPrFXgbgBuprKEoar3JX7cS8IEKaBkXojMA',
    ),
    _HomeCategory(
      title: AppStrings.productHomeCategoryApparel,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB717wQyS9AeENXDPoVWHtgsZS4I3An4etSvXGYlLQlv7KUi9-JhnR3VvdBFzpd35CYGm2yqeQADcqbXIcx_bZuMkNcb4ftRm6cv-d4zNMRKi2puai365v2sDoJTneRoT4LtNAufZpClH6mTsNQ3BOSGKcKAjxSl82R8MwKU9vlYATmJq8p_2iUVerLZLjK8CYZwIDbK_ZcBtBlFWMqvPJikuNwPySWj9CK3N5jcGysAjyUsPR5JZ-okI-Na1ctcuGdiuvpt5QT1xk',
    ),
    _HomeCategory(
      title: AppStrings.productHomeCategoryAccessories,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAqN3fOwg4iAv0K-OFpyptPcv5kI3Iv1cGfh6c3Rzx9NckeONlTagtHJF5OHW9T3H5tYeLq4zwHCRDAQhx2GpRPpSxZ5oO-XPyY1BkNZcw1H2M5XLooFtSRUmwQOFw4AzhzWgn5dege0eP0pSyXVJtWAjWYa1EnShBUT4WiPy4EhfA7rn4CpsyurmFWbHsB948-EkN9cMIgdSCT67_JVLPqnasX_UxQbBvmlAj2dLE8V1OHBXFEmFOKqyw_JDoxodxB5EdVGZy2jVI',
    ),
    _HomeCategory(
      title: AppStrings.productHomeCategoryEquipment,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCbXbEZkYN1PdBUeNwKfJKjjlBmd9AR-t3-OPPhAkxmS-Mgz39vRedxqhOq56wfXTGDPZbfO8HoGyJO5Qe5y34MjqP8pNlntjOGCbOz4huinr3D1M3fBM9zdSaNreqm8JVPI7GaG5s7z6Ol4nZNEt9w_BS5mLwpzD_KieykR9Jljkmk90gdb-zkjv55_oik-Ls1z_O6DBp-rgO6h81liKqVsjE71gmEQjfTU28A42cFidqRRk_MuQaKDdET5xZBolS-dRy434N85hg',
    ),
  ];

  const _HomeCategorySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HomeSectionHeader(),
          const SizedBox(height: AppSizes.fontLg),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSizes.radiusLg),
              itemBuilder: (context, index) => _HomeCategoryCard(
                category: _categories[index],
              ),
            ),
          ),
        ],
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
              color: AppColors.textPrimary,
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
  final _HomeCategory category;

  const _HomeCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(AppRoutes.productList),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(category.imageUrl, fit: BoxFit.cover),
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
                category.title,
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.fontXxl),
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
              : const SizedBox(),
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

class _HomeCategory {
  final String title;
  final String imageUrl;

  const _HomeCategory({
    required this.title,
    required this.imageUrl,
  });
}
