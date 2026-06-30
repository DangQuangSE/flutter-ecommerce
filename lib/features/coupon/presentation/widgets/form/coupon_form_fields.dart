import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/user_tier.dart';

class CouponFormFields extends StatelessWidget {
  final TextEditingController codeController;
  final TextEditingController discountValueController;
  final TextEditingController minOrderController;
  final TextEditingController maxDiscountController;
  final TextEditingController usageLimitController;
  final DiscountType discountType;
  final UserTier? requiredTier;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final ValueChanged<DiscountType> onDiscountTypeChanged;
  final ValueChanged<UserTier?> onRequiredTierChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onClearStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onClearEndDate;
  final ValueChanged<bool> onActiveChanged;

  const CouponFormFields({
    super.key,
    required this.codeController,
    required this.discountValueController,
    required this.minOrderController,
    required this.maxDiscountController,
    required this.usageLimitController,
    required this.discountType,
    required this.requiredTier,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.onDiscountTypeChanged,
    required this.onRequiredTierChanged,
    required this.onPickStartDate,
    required this.onClearStartDate,
    required this.onPickEndDate,
    required this.onClearEndDate,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPercentage = discountType == DiscountType.percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('Mã giảm giá *'),
        TextFormField(
          controller: codeController,
          decoration: _decoration('VD: SUMMER2026'),
          textCapitalization: TextCapitalization.characters,
          maxLength: 50,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
          ],
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Vui lòng nhập mã';
            if (trimmed.length < 3) return 'Mã tối thiểu 3 ký tự';
            return null;
          },
        ),
        const _FieldLabel('Loại giảm giá *'),
        DropdownButtonFormField<DiscountType>(
          initialValue: discountType,
          decoration: _decoration(''),
          items: DiscountType.values
              .map((type) =>
                  DropdownMenuItem(value: type, child: Text(type.label)))
              .toList(),
          onChanged: (value) {
            if (value != null) onDiscountTypeChanged(value);
          },
        ),
        _FieldLabel(
          isPercentage ? 'Giá trị giảm (%) *' : 'Giá trị giảm (đ) *',
        ),
        TextFormField(
          controller: discountValueController,
          decoration: _decoration(isPercentage ? 'VD: 20' : 'VD: 50000'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          validator: (value) {
            final parsed = double.tryParse(value?.trim() ?? '');
            if (parsed == null || parsed <= 0) {
              return 'Vui lòng nhập giá trị hợp lệ';
            }
            if (isPercentage && parsed > 100) {
              return 'Phần trăm không vượt quá 100';
            }
            return null;
          },
        ),
        const _FieldLabel('Đơn hàng tối thiểu (đ)'),
        TextFormField(
          controller: minOrderController,
          decoration: _decoration('Để trống nếu không yêu cầu'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const _FieldLabel('Giảm tối đa (đ)'),
        TextFormField(
          controller: maxDiscountController,
          decoration: _decoration('Áp dụng cho giảm theo %'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Hạng thành viên yêu cầu'),
        DropdownButtonFormField<UserTier?>(
          initialValue: requiredTier,
          decoration: _decoration('Không yêu cầu'),
          items: [
            const DropdownMenuItem<UserTier?>(
              value: null,
              child: Text('Không yêu cầu'),
            ),
            ...UserTier.values.map(
              (tier) => DropdownMenuItem<UserTier?>(
                value: tier,
                child: Text(tier.label),
              ),
            ),
          ],
          onChanged: onRequiredTierChanged,
        ),
        const _FieldLabel('Giới hạn lượt dùng'),
        TextFormField(
          controller: usageLimitController,
          decoration: _decoration('Để trống nếu không giới hạn'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 8),
        CouponDateField(
          label: 'Ngày bắt đầu',
          value: startDate,
          onPick: onPickStartDate,
          onClear: onClearStartDate,
        ),
        CouponDateField(
          label: 'Ngày kết thúc',
          value: endDate,
          onPick: onPickEndDate,
          onClear: onClearEndDate,
        ),
        const SizedBox(height: 8),
        CouponStatusSwitch(
          title: 'Đang hoạt động',
          subtitle: 'Cho phép khách hàng sử dụng mã này',
          value: isActive,
          onChanged: onActiveChanged,
        ),
      ],
    );
  }
}

class CouponDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const CouponDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value == null
                          ? 'Chưa chọn'
                          : DateFormat('dd/MM/yyyy HH:mm').format(value!),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: value == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CouponStatusSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CouponStatusSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        activeThumbColor: AppColors.success,
        onChanged: onChanged,
        title: Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

InputDecoration _decoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textHint),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: _fieldBorder(),
    enabledBorder: _fieldBorder(),
    focusedBorder: _fieldBorder(color: AppColors.primary, width: 1.5),
  );
}

OutlineInputBorder _fieldBorder({
  Color color = AppColors.divider,
  double width = 1,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}
