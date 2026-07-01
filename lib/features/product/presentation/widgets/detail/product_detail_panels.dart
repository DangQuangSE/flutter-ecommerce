import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/collapsible_panel.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_state.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_state.dart';

class ProductDetailPanels extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailPanels({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          CollapsiblePanel(
            title: AppStrings.specsTitle,
            child: Text(
              product.description.isNotEmpty
                  ? product.description
                  : AppStrings.noProductDescription,
              style: _bodyStyle(),
            ),
          ),
          const CollapsiblePanel(
            title: AppStrings.returnPolicyTitle,
            child: _ReturnPolicyPanel(),
          ),
          CollapsiblePanel(
            title: AppStrings.reviewsTitle(product.reviewCount),
            child: const _ProductReviewsPanel(),
          ),
        ],
      ),
    );
  }
}

class _ProductReviewsPanel extends StatelessWidget {
  const _ProductReviewsPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state is ReviewLoading || state is ReviewInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSm),
              child: AppLoadingView(size: AppSizes.paddingXl),
            ),
          );
        }
        if (state is ReviewError) {
          return Text(AppStrings.reviewsLoadError, style: _bodyStyle());
        }
        if (state is ReviewLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < state.reviews.length; i++) ...[
                if (i > 0) const Divider(height: 16, color: Color(0xFFE8E8ED)),
                _ReviewRow(review: state.reviews[i]),
              ],
            ],
          );
        }
        return Text(AppStrings.noReviewsYet, style: _bodyStyle());
      },
    );
  }
}

class _ReturnPolicyPanel extends StatelessWidget {
  const _ReturnPolicyPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteSettingCubit, SiteSettingState>(
      builder: (context, state) {
        final content = switch (state) {
          SiteSettingLoaded(:final settings)
              when settings.returnPolicy.isEmpty =>
            AppStrings.returnPolicyEmpty,
          SiteSettingLoaded() => state.settings.returnPolicy,
          SiteSettingError() => AppStrings.returnPolicyLoadError,
          _ => AppStrings.returnPolicyLoading,
        };
        return Text(content, style: _bodyStyle());
      },
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final ReviewEntity review;

  const _ReviewRow({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              review.userName,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  color: index < review.rating
                      ? AppColors.accent
                      : const Color(0xFFC1C6D7),
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(review.comment, style: _bodyStyle()),
        _ReviewImages(imageUrls: review.images),
      ],
    );
  }
}

class _ReviewImages extends StatelessWidget {
  final List<String> imageUrls;

  const _ReviewImages({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.where((url) => url.trim().isNotEmpty).toList();
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.paddingSm),
      child: SizedBox(
        height: AppSizes.reviewImageSize,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: urls.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSizes.paddingSm),
          itemBuilder: (context, index) => _ReviewImage(
            url: urls[index],
            onTap: () => _showReviewImageViewer(
              context,
              imageUrls: urls,
              initialIndex: index,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewImage extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const _ReviewImage({
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Image.network(
          url,
          width: AppSizes.reviewImageSize,
          height: AppSizes.reviewImageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: AppSizes.reviewImageSize,
            height: AppSizes.reviewImageSize,
            color: AppColors.divider,
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: AppSizes.iconSm,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

void _showReviewImageViewer(
  BuildContext context, {
  required List<String> imageUrls,
  required int initialIndex,
}) {
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => Dialog.fullscreen(
      backgroundColor: AppColors.black,
      child: _ReviewImageViewer(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
      ),
    ),
  );
}

class _ReviewImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ReviewImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ReviewImageViewer> createState() => _ReviewImageViewerState();
}

class _ReviewImageViewerState extends State<_ReviewImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: AppSizes.iconLg,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSizes.paddingSm,
              right: AppSizes.paddingSm,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(),
                  iconSize: AppSizes.iconLg,
                  padding: const EdgeInsets.all(AppSizes.paddingMd),
                  icon: const Icon(Icons.close_rounded, color: AppColors.white),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSizes.paddingLg,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMd,
                      vertical: AppSizes.paddingSm,
                    ),
                    child: Text(
                      AppStrings.reviewImageCounter(
                        _currentIndex + 1,
                        widget.imageUrls.length,
                      ),
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle _bodyStyle() {
  return GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
  );
}
