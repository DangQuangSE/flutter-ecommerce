import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/user_tier.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';

class CouponFormPage extends StatefulWidget {
  /// Existing coupon when editing; null when creating.
  final CouponEntity? coupon;

  const CouponFormPage({super.key, this.coupon});

  bool get isEditing => coupon != null;

  @override
  State<CouponFormPage> createState() => _CouponFormPageState();
}

class _CouponFormPageState extends State<CouponFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late final TextEditingController _codeController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _maxDiscountController;
  late final TextEditingController _usageLimitController;

  late DiscountType _discountType;
  UserTier? _requiredTier;
  DateTime? _startDate;
  DateTime? _endDate;
  late bool _isActive;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _codeController = TextEditingController(text: c?.code ?? '');
    _discountValueController = TextEditingController(
        text: c == null ? '' : _trimNumber(c.discountValue));
    _minOrderController = TextEditingController(
        text: c?.minOrderAmount == null ? '' : _trimNumber(c!.minOrderAmount!));
    _maxDiscountController = TextEditingController(
        text: c?.maxDiscountAmount == null
            ? ''
            : _trimNumber(c!.maxDiscountAmount!));
    _usageLimitController =
        TextEditingController(text: c?.usageLimit?.toString() ?? '');
    _discountType = c?.discountType ?? DiscountType.percentage;
    _requiredTier = c?.requiredTier;
    _startDate = c?.startDate;
    _endDate = c?.endDate;
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  static String _trimNumber(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  double? _parseAmount(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final base = initial ?? now;
    // Widen the window so an existing (possibly old/future) value is always a
    // valid initialDate — showDatePicker asserts firstDate <= initialDate <= lastDate.
    final defaultFirst = DateTime(now.year - 1);
    final defaultLast = DateTime(now.year + 5, 12, 31);
    final firstDate = base.isBefore(defaultFirst)
        ? DateTime(base.year, base.month, base.day)
        : defaultFirst;
    final lastDate = base.isAfter(defaultLast)
        ? DateTime(base.year, base.month, base.day)
        : defaultLast;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
    );
    return DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      _showSnack('Ngày kết thúc phải sau ngày bắt đầu', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final draft = CouponEntity(
      id: widget.coupon?.id,
      code: _codeController.text.trim().toUpperCase(),
      discountType: _discountType,
      discountValue: double.parse(_discountValueController.text.trim()),
      minOrderAmount: _parseAmount(_minOrderController.text),
      maxDiscountAmount: _parseAmount(_maxDiscountController.text),
      requiredTier: _requiredTier,
      startDate: _startDate,
      endDate: _endDate,
      usageLimit: int.tryParse(_usageLimitController.text.trim()),
      usedCount: widget.coupon?.usedCount ?? 0,
      isActive: _isActive,
    );

    final cubit = context.read<CouponCubit>();
    final error = widget.isEditing
        ? await cubit.update(widget.coupon!.id!, draft)
        : await cubit.create(draft);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(
              widget.isEditing ? 'Đã cập nhật mã giảm giá' : 'Đã tạo mã giảm giá'),
          backgroundColor: AppColors.success,
        ));
      Navigator.of(context).pop();
    } else {
      _showSnack(error, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final isPercentage = _discountType == DiscountType.percentage;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditing ? 'Sửa mã giảm giá' : 'Thêm mã giảm giá',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _label('Mã giảm giá *'),
            TextFormField(
              controller: _codeController,
              decoration: _decoration('VD: SUMMER2026'),
              textCapitalization: TextCapitalization.characters,
              maxLength: 50,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_-]')),
              ],
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Vui lòng nhập mã';
                if (value.length < 3) return 'Mã tối thiểu 3 ký tự';
                return null;
              },
            ),
            _label('Loại giảm giá *'),
            DropdownButtonFormField<DiscountType>(
              initialValue: _discountType,
              decoration: _decoration(''),
              items: DiscountType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _discountType = value);
              },
            ),
            _label(isPercentage ? 'Giá trị giảm (%) *' : 'Giá trị giảm (đ) *'),
            TextFormField(
              controller: _discountValueController,
              decoration: _decoration(isPercentage ? 'VD: 20' : 'VD: 50000'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: (v) {
                final value = double.tryParse(v?.trim() ?? '');
                if (value == null || value <= 0) {
                  return 'Vui lòng nhập giá trị hợp lệ';
                }
                if (isPercentage && value > 100) {
                  return 'Phần trăm không vượt quá 100';
                }
                return null;
              },
            ),
            _label('Đơn hàng tối thiểu (đ)'),
            TextFormField(
              controller: _minOrderController,
              decoration: _decoration('Để trống nếu không yêu cầu'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _label('Giảm tối đa (đ)'),
            TextFormField(
              controller: _maxDiscountController,
              decoration: _decoration('Áp dụng cho giảm theo %'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            _label('Hạng thành viên yêu cầu'),
            DropdownButtonFormField<UserTier?>(
              initialValue: _requiredTier,
              decoration: _decoration('Không yêu cầu'),
              items: [
                const DropdownMenuItem<UserTier?>(
                  value: null,
                  child: Text('Không yêu cầu'),
                ),
                ...UserTier.values.map((t) =>
                    DropdownMenuItem<UserTier?>(value: t, child: Text(t.label))),
              ],
              onChanged: (value) => setState(() => _requiredTier = value),
            ),
            _label('Giới hạn lượt dùng'),
            TextFormField(
              controller: _usageLimitController,
              decoration: _decoration('Để trống nếu không giới hạn'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),
            _dateField(
              label: 'Ngày bắt đầu',
              value: _startDate,
              onPick: () async {
                final picked = await _pickDateTime(_startDate);
                if (picked != null) setState(() => _startDate = picked);
              },
              onClear: () => setState(() => _startDate = null),
            ),
            _dateField(
              label: 'Ngày kết thúc',
              value: _endDate,
              onPick: () async {
                final picked = await _pickDateTime(_endDate);
                if (picked != null) setState(() => _endDate = picked);
              },
              onClear: () => setState(() => _endDate = null),
            ),
            const SizedBox(height: 8),
            _buildSwitch(
              title: 'Đang hoạt động',
              subtitle: 'Cho phép khách hàng sử dụng mã này',
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'Lưu thay đổi' : 'Tạo mã giảm giá',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
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

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
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
              const Icon(Icons.event_rounded,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      value == null ? 'Chưa chọn' : _dateFormat.format(value),
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

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFC1C6D7).withValues(alpha: 0.3)),
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
              color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textHint),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
