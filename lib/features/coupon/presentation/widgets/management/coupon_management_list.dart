import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: filtered.isEmpty ? 2 : filtered.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            query.isEmpty
                ? '${state.totalElements} mã giảm giá'
                : '$filteredCount/${state.coupons.length} mã',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (state.isMutating)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
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
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          'Không có mã nào khớp "$query".',
          style: GoogleFonts.inter(
            fontSize: 13,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _CouponIcon(inactive: inactive),
            const SizedBox(width: 12),
            Expanded(child: _CouponSummary(coupon: coupon)),
            Switch.adaptive(
              value: coupon.isActive,
              activeThumbColor: AppColors.success,
              onChanged: (_) => onToggle(coupon),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit(coupon);
                if (value == 'delete') onDelete(coupon);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Sửa')),
                PopupMenuItem(value: 'delete', child: Text('Xóa')),
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
        borderRadius: BorderRadius.circular(10),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _DiscountChip(coupon: coupon),
          ],
        ),
        const SizedBox(height: 3),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '-${_discountText(coupon)}',
        style: GoogleFonts.lexend(
          fontSize: 11,
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
          ? 'Đã dùng ${coupon.usedCount}/${coupon.usageLimit}'
          : 'Đã dùng ${coupon.usedCount}',
    ];

    if (coupon.endDate != null) {
      parts.add('HSD ${DateFormat('dd/MM/yyyy').format(coupon.endDate!)}');
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
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (tag != null) ...[
          const SizedBox(width: 6),
          _CouponStatusTag(tag: tag),
        ],
      ],
    );
  }

  _CouponStatus? _statusTag(CouponEntity coupon) {
    if (coupon.isExpired) {
      return const _CouponStatus('Hết hạn', AppColors.error);
    }
    if (coupon.isUsedUp) {
      return const _CouponStatus('Hết lượt', AppColors.warning);
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag.label,
        style: GoogleFonts.inter(
          fontSize: 9,
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
