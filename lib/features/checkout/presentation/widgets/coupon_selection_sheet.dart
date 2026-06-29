import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/coupon_manual_code_form.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/coupon_voucher_card.dart';

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
    setState(() {
      _errorMessage = null;
    });
    final typedCode = _codeController.text.trim().toUpperCase();
    if (typedCode.isEmpty) return;

    final match = widget.coupons.firstWhere(
      (c) => c.code.toUpperCase() == typedCode,
      orElse: () => const CouponEntity(code: ''),
    );

    if (match.code.isEmpty) {
      setState(() {
        _errorMessage = 'Mã giảm giá không hợp lệ hoặc đã hết hạn';
      });
      return;
    }

    if (match.minOrderAmount != null &&
        widget.subtotal < match.minOrderAmount!) {
      setState(() {
        _errorMessage = 'Đơn hàng chưa đạt giá trị tối thiểu';
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
    // Keep viewInsets padding OUTSIDE the SizedBox that has a fixed height,
    // otherwise the keyboard's resize animation fights the fixed height
    // mid-layout.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFC1C6D7).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn Sport Pro Voucher',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            CouponManualCodeForm(
              controller: _codeController,
              errorMessage: _errorMessage,
              onApply: _applyManualCode,
            ),
            const Divider(height: 1),
            Expanded(
              child: _buildCouponList(),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onCouponSelected(_tempSelectedCoupon);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ), // Column
      ), // SizedBox
    ); // Padding (keyboard inset wrapper)
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmptyVouchers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.confirmation_num_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            'Không có mã giảm giá nào',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList() {
    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
    for (final c in coupons) {
      if (c.minOrderAmount != null && widget.subtotal < c.minOrderAmount!) {
        ineligible.add(c);
      } else {
        eligible.add(c);
      }
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        if (eligible.isNotEmpty) ...[
          _buildSectionLabel('MÃ GIẢM GIÁ KHẢ DỤNG'),
          const SizedBox(height: 8),
          ...eligible.map((c) => CouponVoucherCard(
                coupon: c,
                isEligible: true,
                isSelected: _tempSelectedCoupon?.code == c.code,
                formatPrice: _formatPrice,
                onSelect: () {
                  setState(() {
                    _tempSelectedCoupon = c;
                  });
                },
              )),
        ],
        if (ineligible.isNotEmpty) ...[
          if (eligible.isNotEmpty) const SizedBox(height: 24),
          _buildSectionLabel('MÃ KHÔNG KHẢ DỤNG'),
          const SizedBox(height: 8),
          ...ineligible.map((c) => CouponVoucherCard(
                coupon: c,
                isEligible: false,
                isSelected: false,
                formatPrice: _formatPrice,
                onSelect: () {},
              )),
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
