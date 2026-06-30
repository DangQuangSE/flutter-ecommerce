import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';

class BrandFormSheet extends StatefulWidget {
  final BrandEntity? brand;
  final ValueChanged<BrandEntity> onSubmit;

  const BrandFormSheet({
    super.key,
    this.brand,
    required this.onSubmit,
  });

  @override
  State<BrandFormSheet> createState() => _BrandFormSheetState();
}

class _BrandFormSheetState extends State<BrandFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _logoController;
  late final TextEditingController _countryController;
  late final TextEditingController _webController;
  late bool _isActive;

  bool get _isEditing => widget.brand != null;

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    _nameController = TextEditingController(text: brand?.name ?? '');
    _descController = TextEditingController(text: brand?.description ?? '');
    _logoController = TextEditingController(text: brand?.logoUrl ?? '');
    _countryController = TextEditingController(text: brand?.country ?? '');
    _webController = TextEditingController(text: brand?.websiteUrl ?? '');
    _isActive = brand?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _logoController.dispose();
    _countryController.dispose();
    _webController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.length < 2 || name.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên thương hiệu phải từ 2 đến 100 ký tự!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSubmit(
      BrandEntity(
        id: widget.brand?.id,
        name: name,
        slug: widget.brand?.slug ?? '',
        description: _descController.text.trim(),
        logoUrl: _logoController.text.trim(),
        country: _countryController.text.trim(),
        websiteUrl: _webController.text.trim(),
        isActive: _isActive,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHeader(
              isEditing: _isEditing,
              onClose: () => Navigator.pop(context),
            ),
            const Divider(),
            const SizedBox(height: 12),
            const _FieldLabel('TÊN THƯƠNG HIỆU'),
            _BrandTextField(
              controller: _nameController,
              hintText: 'Nhập tên thương hiệu (ví dụ: Nike)',
            ),
            const SizedBox(height: 16),
            const _FieldLabel('QUỐC GIA'),
            _BrandTextField(
              controller: _countryController,
              hintText: 'Ví dụ: USA, Vietnam',
            ),
            const SizedBox(height: 16),
            const _FieldLabel('WEBSITE'),
            _BrandTextField(
              controller: _webController,
              hintText: 'Ví dụ: https://www.nike.com',
            ),
            const SizedBox(height: 16),
            const _FieldLabel('LOGO URL'),
            _BrandTextField(
              controller: _logoController,
              hintText: 'Nhập URL hình ảnh logo',
            ),
            const SizedBox(height: 16),
            const _FieldLabel('MÔ TẢ'),
            _BrandTextField(
              controller: _descController,
              hintText: 'Nhập mô tả về thương hiệu...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _ActiveSwitch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
              ),
              child: Text(
                _isEditing ? 'LƯU THAY ĐỔI' : 'THÊM THƯƠNG HIỆU',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.isEditing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditing ? 'Chỉnh sửa thương hiệu' : 'Thêm thương hiệu mới',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BrandTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _BrandTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: maxLines > 1
            ? const EdgeInsets.all(12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ActiveSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _FieldLabel('TRẠNG THÁI HOẠT ĐỘNG'),
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
