import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/user_tier.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/form/coupon_form_app_bar.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/form/coupon_form_fields.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/form/coupon_submit_button.dart';

class CouponFormPage extends StatefulWidget {
  final CouponEntity? coupon;

  const CouponFormPage({super.key, this.coupon});

  bool get isEditing => coupon != null;

  @override
  State<CouponFormPage> createState() => _CouponFormPageState();
}

class _CouponFormPageState extends State<CouponFormPage> {
  final _formKey = GlobalKey<FormState>();

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
    final coupon = widget.coupon;
    _codeController = TextEditingController(text: coupon?.code ?? '');
    _discountValueController = TextEditingController(
      text: coupon == null ? '' : _trimNumber(coupon.discountValue),
    );
    _minOrderController = TextEditingController(
      text: coupon?.minOrderAmount == null
          ? ''
          : _trimNumber(coupon!.minOrderAmount!),
    );
    _maxDiscountController = TextEditingController(
      text: coupon?.maxDiscountAmount == null
          ? ''
          : _trimNumber(coupon!.maxDiscountAmount!),
    );
    _usageLimitController =
        TextEditingController(text: coupon?.usageLimit?.toString() ?? '');
    _discountType = coupon?.discountType ?? DiscountType.percentage;
    _requiredTier = coupon?.requiredTier;
    _startDate = coupon?.startDate;
    _endDate = coupon?.endDate;
    _isActive = coupon?.isActive ?? true;
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

  static String _trimNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  double? _parseAmount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final base = initial ?? now;
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
      _showSnack(
        widget.isEditing ? 'Đã cập nhật mã giảm giá' : 'Đã tạo mã giảm giá',
      );
      Navigator.of(context).pop();
    } else {
      _showSnack(error, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
        ),
      );
  }

  Future<void> _pickStartDate() async {
    final picked = await _pickDateTime(_startDate);
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await _pickDateTime(_endDate);
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CouponFormAppBar(isEditing: widget.isEditing),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            CouponFormFields(
              codeController: _codeController,
              discountValueController: _discountValueController,
              minOrderController: _minOrderController,
              maxDiscountController: _maxDiscountController,
              usageLimitController: _usageLimitController,
              discountType: _discountType,
              requiredTier: _requiredTier,
              startDate: _startDate,
              endDate: _endDate,
              isActive: _isActive,
              onDiscountTypeChanged: (value) {
                setState(() => _discountType = value);
              },
              onRequiredTierChanged: (value) {
                setState(() => _requiredTier = value);
              },
              onPickStartDate: _pickStartDate,
              onClearStartDate: () => setState(() => _startDate = null),
              onPickEndDate: _pickEndDate,
              onClearEndDate: () => setState(() => _endDate = null),
              onActiveChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 24),
            CouponSubmitButton(
              isEditing: widget.isEditing,
              isSubmitting: _submitting,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
