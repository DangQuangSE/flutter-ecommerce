import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/coupon_manual_code_form.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/coupon_voucher_card.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';

class CouponSelectionSheet extends StatefulWidget {
  final double subtotal;
  final CouponEntity? selectedCoupon;
  final List<CouponEntity> coupons;
  final String? errorMessage;
  final ValueSetter<CouponEntity?> onCouponSelected;

  const CouponSelectionSheet({
    super.key,
    required this.subtotal,
    this.selectedCoupon,
    required this.coupons,
    this.errorMessage,
    required this.onCouponSelected,
  });

  @override
  State<CouponSelectionSheet> createState() => _CouponSelectionSheetState();
}

class _CouponSelectionSheetState extends State<CouponSelectionSheet> {
  final _codeController = TextEditingController();
  CouponEntity? _tempSelectedCoupon;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tempSelectedCoupon = widget.selectedCoupon;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _applyManualCode() {
    setState(() => _errorMessage = null);
    final typedCode = _codeController.text.trim().toUpperCase();
    if (typedCode.isEmpty) return;

    final match = widget.coupons.firstWhere(
      (coupon) => coupon.code.toUpperCase() == typedCode,
      orElse: () => const CouponEntity(code: ''),
    );

    if (match.code.isEmpty) {
      setState(() {
        _errorMessage = AppStrings.checkoutCouponInvalid;
      });
      return;
    }

    if (match.minOrderAmount != null &&
        widget.subtotal < match.minOrderAmount!) {
      setState(() {
        _errorMessage = AppStrings.checkoutCouponMinOrderNotMet;
      });
      return;
    }

    setState(() {
      _tempSelectedCoupon = match;
      _codeController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listMaxHeight = MediaQuery.sizeOf(context).height * 0.4;

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingMd,
              AppSizes.radiusLg,
              AppSizes.paddingXs,
              AppSizes.paddingXs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.checkoutCouponPickerTitle,
                    style: GoogleFonts.lexend(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: AppSizes.iconMd,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          CouponManualCodeForm(
            controller: _codeController,
            errorMessage: _errorMessage,
            onApply: _applyManualCode,
          ),
          Divider(height: 1, color: theme.dividerColor),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: listMaxHeight),
            child: _buildCouponList(),
          ),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: ElevatedButton(
              onPressed: () => widget.onCouponSelected(_tempSelectedCoupon),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.paddingSm),
                ),
              ),
              child: Text(
                AppStrings.ok,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmptyVouchers() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_num_outlined,
              size: AppSizes.iconXxl,
              color: AppColors.textHint,
            ),
            SizedBox(height: AppSizes.radiusLg),
            Text(
              AppStrings.checkoutCouponEmpty,
              style: GoogleFonts.inter(
                fontSize: AppSizes.forgotPasswordFontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponList() {
    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXl),
          child: Text(
            widget.errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.error),
          ),
        ),
      );
    }
    if (widget.coupons.isEmpty) return _buildEmptyVouchers();
    return _buildCouponListView(widget.coupons);
  }

  Widget _buildCouponListView(List<CouponEntity> coupons) {
    final eligible = <CouponEntity>[];
    final ineligible = <CouponEntity>[];
    for (final coupon in coupons) {
      if (coupon.minOrderAmount != null &&
          widget.subtotal < coupon.minOrderAmount!) {
        ineligible.add(coupon);
      } else {
        eligible.add(coupon);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      physics: const BouncingScrollPhysics(),
      children: [
        if (eligible.isNotEmpty) ...[
          _buildSectionLabel(AppStrings.checkoutCouponAvailableSection),
          SizedBox(height: AppSizes.paddingSm),
          ...eligible.map(
            (coupon) => CouponVoucherCard(
              coupon: coupon,
              isEligible: true,
              isSelected: _tempSelectedCoupon?.code == coupon.code,
              formatPrice: _formatPrice,
              onSelect: () {
                setState(() => _tempSelectedCoupon = coupon);
              },
            ),
          ),
        ],
        if (ineligible.isNotEmpty) ...[
          if (eligible.isNotEmpty) SizedBox(height: AppSizes.paddingXl),
          _buildSectionLabel(AppStrings.checkoutCouponUnavailableSection),
          SizedBox(height: AppSizes.paddingSm),
          ...ineligible.map(
            (coupon) => CouponVoucherCard(
              coupon: coupon,
              isEligible: false,
              isSelected: false,
              formatPrice: _formatPrice,
              onSelect: () {},
            ),
          ),
        ],
      ],
    );
  }

  String _formatPrice(double price) {
    final formatStr = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < formatStr.length; i++) {
      buffer.write(formatStr[i]);
      if ((formatStr.length - 1 - i) % 3 == 0 && i != formatStr.length - 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}
