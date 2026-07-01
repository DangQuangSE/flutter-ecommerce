import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_state.dart';

class CouponManagementList extends StatelessWidget {
  final CouponLoaded state;
  final List<CouponEntity> filtered;
  final String query;
  final Future<void> Function() onRefresh;
  final ValueChanged<CouponEntity> onOpenDetail;
  final ValueChanged<CouponEntity> onEdit;
  final ValueChanged<CouponEntity> onDelete;
  final ValueChanged<CouponEntity> onToggle;

  const CouponManagementList({
    super.key,
    required this.state,
    required this.filtered,
    required this.query,
    required this.onRefresh,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingXs,
          AppSizes.paddingMd,
          96,
        ),
        itemCount: filtered.isEmpty ? 2 : filtered.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: AppSizes.radiusMd),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CouponListHeader(
              state: state,
              filteredCount: filtered.length,
              query: query,
            );
          }

          if (filtered.isEmpty) {
            return _CouponNoMatches(query: query);
          }

          return _CouponTile(
            coupon: filtered[index - 1],
            onOpenDetail: onOpenDetail,
            onEdit: onEdit,
            onDelete: onDelete,
            onToggle: onToggle,
          );
        },
      ),
    );
  }
}

class _CouponListHeader extends StatelessWidget {
  final CouponLoaded state;
  final int filteredCount;
  final String query;

  const _CouponListHeader({
    required this.state,
    required this.filteredCount,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            query.isEmpty
                ? AppStrings.adminCouponTotalCount(state.totalElements)
                : AppStrings.adminCouponFilteredCount(
                    filteredCount,
                    state.coupons.length,
                  ),
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (state.isMutating)
            const SizedBox.square(
              dimension: AppSizes.iconSm,
              child: AppLoadingView(size: AppSizes.iconSm),
            ),
        ],
      ),
    );
  }
}

class _CouponNoMatches extends StatelessWidget {
  final String query;

  const _CouponNoMatches({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.fontDisplay + 8),
      child: Center(
        child: Text(
          AppStrings.adminCouponNoMatches(query),
          style: GoogleFonts.inter(
            fontSize: AppSizes.forgotPasswordFontSize,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  final CouponEntity coupon;
  final ValueChanged<CouponEntity> onOpenDetail;
  final ValueChanged<CouponEntity> onEdit;
  final ValueChanged<CouponEntity> onDelete;
  final ValueChanged<CouponEntity> onToggle;

  const _CouponTile({
    required this.coupon,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final inactive = !coupon.isActive || coupon.isExpired || coupon.isUsedUp;

    return GestureDetector(
      onTap: () => onOpenDetail(coupon),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg - 6,
          vertical: AppSizes.paddingSm + 2,
        ),
        child: Row(
          children: [
            _CouponIcon(inactive: inactive),
            SizedBox(width: AppSizes.paddingSm + AppSizes.paddingXs),
            Expanded(child: _CouponSummary(coupon: coupon)),
            Switch.adaptive(
              value: coupon.isActive,
              activeThumbColor: AppColors.success,
              onChanged: (_) => onToggle(coupon),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit(coupon);
                if (value == 'delete') onDelete(coupon);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text(AppStrings.edit)),
                PopupMenuItem(value: 'delete', child: Text(AppStrings.delete)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponIcon extends StatelessWidget {
  final bool inactive;

  const _CouponIcon({required this.inactive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: (inactive ? AppColors.textSecondary : AppColors.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Icon(
        Icons.local_offer_rounded,
        color: inactive ? AppColors.textSecondary : AppColors.primary,
      ),
    );
  }
}

class _CouponSummary extends StatelessWidget {
  final CouponEntity coupon;

  const _CouponSummary({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                coupon.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: AppSizes.radiusSm),
            _DiscountChip(coupon: coupon),
          ],
        ),
        SizedBox(height: AppSizes.paddingXs - 1),
        _CouponSubtitle(coupon: coupon),
      ],
    );
  }
}

class _DiscountChip extends StatelessWidget {
  final CouponEntity coupon;

  const _DiscountChip({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: AppSizes.paddingXs / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        '-${_discountText(coupon)}',
        style: GoogleFonts.lexend(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
        ),
      ),
    );
  }

  String _discountText(CouponEntity coupon) {
    if (coupon.discountType == DiscountType.percentage) {
      final value = coupon.discountValue;
      final whole =
          value == value.roundToDouble() ? value.toInt().toString() : '$value';
      return '$whole%';
    }

    return '${NumberFormat.decimalPattern('vi_VN').format(coupon.discountValue)}đ';
  }
}

class _CouponSubtitle extends StatelessWidget {
  final CouponEntity coupon;

  const _CouponSubtitle({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      coupon.usageLimit != null
          ? AppStrings.adminCouponUsedWithLimit(
              coupon.usedCount,
              coupon.usageLimit!,
            )
          : AppStrings.adminCouponUsed(coupon.usedCount),
    ];

    if (coupon.endDate != null) {
      parts.add(
        AppStrings.adminCouponExpires(
          DateFormat('dd/MM/yyyy').format(coupon.endDate!),
        ),
      );
    }

    final tag = _statusTag(coupon);

    return Row(
      children: [
        Flexible(
          child: Text(
            parts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (tag != null) ...[
          SizedBox(width: AppSizes.radiusSm),
          _CouponStatusTag(tag: tag),
        ],
      ],
    );
  }

  _CouponStatus? _statusTag(CouponEntity coupon) {
    if (coupon.isExpired) {
      return const _CouponStatus(
          AppStrings.adminCouponExpired, AppColors.error);
    }
    if (coupon.isUsedUp) {
      return const _CouponStatus(
          AppStrings.adminCouponUsedUp, AppColors.warning);
    }

    return null;
  }
}

class _CouponStatusTag extends StatelessWidget {
  final _CouponStatus tag;

  const _CouponStatusTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.radiusSm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.paddingXs),
      ),
      child: Text(
        tag.label,
        style: GoogleFonts.inter(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
          color: tag.color,
        ),
      ),
    );
  }
}

class _CouponStatus {
  final String label;
  final Color color;

  const _CouponStatus(this.label, this.color);
}
