import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';

class CategoryFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController imageUrlController;
  final TextEditingController displayOrderController;
  final List<CategoryEntity> parentOptions;
  final int? parentId;
  final bool isActive;
  final bool isCustomizable;
  final ValueChanged<int?> onParentChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onCustomizableChanged;

  const CategoryFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.imageUrlController,
    required this.displayOrderController,
    required this.parentOptions,
    required this.parentId,
    required this.isActive,
    required this.isCustomizable,
    required this.onParentChanged,
    required this.onActiveChanged,
    required this.onCustomizableChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('Tên danh mục *'),
        TextFormField(
          controller: nameController,
          decoration: _decoration('VD: Giày chạy bộ'),
          maxLength: 100,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Vui lòng nhập tên';
            if (trimmed.length < 2) return 'Tên tối thiểu 2 ký tự';
            return null;
          },
        ),
        const _FieldLabel('Mô tả'),
        TextFormField(
          controller: descriptionController,
          decoration: _decoration('Mô tả ngắn về danh mục'),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Danh mục cha'),
        DropdownButtonFormField<int?>(
          initialValue: parentId,
          decoration: _decoration('Không có (danh mục gốc)'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Không có (danh mục gốc)'),
            ),
            ...parentOptions.map(
              (parent) => DropdownMenuItem<int?>(
                value: parent.id,
                child: Text(parent.name, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onParentChanged,
        ),
        const _FieldLabel('Ảnh (URL)'),
        TextFormField(
          controller: imageUrlController,
          decoration: _decoration('https://...'),
          keyboardType: TextInputType.url,
        ),
        const _FieldLabel('Thứ tự hiển thị'),
        TextFormField(
          controller: displayOrderController,
          decoration: _decoration('VD: 1'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 8),
        CategoryStatusSwitch(
          title: 'Đang hoạt động',
          subtitle: 'Hiển thị danh mục cho khách hàng',
          value: isActive,
          onChanged: onActiveChanged,
        ),
        CategoryStatusSwitch(
          title: 'Cho phép tùy chỉnh',
          subtitle: 'Sản phẩm trong danh mục có thể tùy biến',
          value: isCustomizable,
          onChanged: onCustomizableChanged,
        ),
      ],
    );
  }
}

class CategoryStatusSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CategoryStatusSwitch({
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
