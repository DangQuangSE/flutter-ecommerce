import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection();

  static const double _stripHeight = 120;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
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
              const HomeSectionHeader(),
              const SizedBox(height: AppSizes.fontLg),
              SizedBox(
                height: _stripHeight,
                child: isLoading
                    ? const HomeCategoryStripPlaceholder()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingLg),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSizes.radiusLg),
                        itemBuilder: (context, index) => HomeCategoryCard(
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

class HomeCategoryStripPlaceholder extends StatelessWidget {
  const HomeCategoryStripPlaceholder();

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

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.productHomeCategoriesTitle,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: () => context.goNamed(AppRoutes.productList),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.productHomeViewAll,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCategoryCard extends StatefulWidget {
  final CategoryEntity category;

  const HomeCategoryCard({super.key, required this.category});

  @override
  State<HomeCategoryCard> createState() => _HomeCategoryCardState();
}

class _HomeCategoryCardState extends State<HomeCategoryCard> {
  double _scale = 1.0;

  void _openCategory(BuildContext context) {
    context.goNamed(
      AppRoutes.productList,
      extra: {
        'categoryId': widget.category.id,
        'categoryName': widget.category.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.category.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        _openCategory(context);
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ??
                Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155).withValues(alpha: 0.5)
                  : Theme.of(context).dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const HomeCategoryImageFallback(),
                  errorWidget: (context, url, error) =>
                      const HomeCategoryImageFallback(),
                )
              else
                const HomeCategoryImageFallback(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        widget.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeCategoryImageFallback extends StatelessWidget {
  const HomeCategoryImageFallback();

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
