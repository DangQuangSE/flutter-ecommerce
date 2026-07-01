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
          CollapsiblePanel(
            title: AppStrings.reviewsTitle(product.reviewCount),
            child: const _ProductReviewsPanel(),
          ),
          const CollapsiblePanel(
            title: AppStrings.returnPolicyTitle,
            child: _ReturnPolicyPanel(),
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
      ],
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
