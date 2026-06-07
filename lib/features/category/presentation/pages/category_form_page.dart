import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';

class CategoryFormPage extends StatefulWidget {
  /// Existing category when editing; null when creating.
  final CategoryEntity? category;

  /// Categories selectable as a parent (excludes the one being edited).
  final List<CategoryEntity> parents;

  const CategoryFormPage({
    super.key,
    this.category,
    this.parents = const [],
  });

  bool get isEditing => category != null;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _displayOrderController;

  int? _parentId;
  late bool _isActive;
  late bool _isCustomizable;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _imageUrlController = TextEditingController(text: c?.imageUrl ?? '');
    _displayOrderController =
        TextEditingController(text: c?.displayOrder?.toString() ?? '');
    _parentId = c?.parentId;
    _isActive = c?.isActive ?? true;
    _isCustomizable = c?.isCustomizable ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  /// Parent options excluding the category being edited (can't be its own parent).
  List<CategoryEntity> get _parentOptions => widget.parents
      .where((p) => p.id != null && p.id != widget.category?.id)
      .toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final draft = CategoryEntity(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      parentId: _parentId,
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      displayOrder: int.tryParse(_displayOrderController.text.trim()),
      isActive: _isActive,
      isCustomizable: _isCustomizable,
    );

    final cubit = context.read<CategoryCubit>();
    final error = widget.isEditing
        ? await cubit.update(widget.category!.id!, draft)
        : await cubit.create(draft);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(
              widget.isEditing ? 'Đã cập nhật danh mục' : 'Đã tạo danh mục'),
          backgroundColor: AppColors.success,
        ));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          widget.isEditing ? 'Sửa danh mục' : 'Thêm danh mục',
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
            _label('Tên danh mục *'),
            TextFormField(
              controller: _nameController,
              decoration: _decoration('VD: Giày chạy bộ'),
              maxLength: 100,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Vui lòng nhập tên';
                if (value.length < 2) return 'Tên tối thiểu 2 ký tự';
                return null;
              },
            ),
            _label('Mô tả'),
            TextFormField(
              controller: _descriptionController,
              decoration: _decoration('Mô tả ngắn về danh mục'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _label('Danh mục cha'),
            DropdownButtonFormField<int?>(
              initialValue: _parentId,
              decoration: _decoration('Không có (danh mục gốc)'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Không có (danh mục gốc)'),
                ),
                ..._parentOptions.map((p) => DropdownMenuItem<int?>(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (value) => setState(() => _parentId = value),
            ),
            _label('Ảnh (URL)'),
            TextFormField(
              controller: _imageUrlController,
              decoration: _decoration('https://...'),
              keyboardType: TextInputType.url,
            ),
            _label('Thứ tự hiển thị'),
            TextFormField(
              controller: _displayOrderController,
              decoration: _decoration('VD: 1'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),
            _buildSwitch(
              title: 'Đang hoạt động',
              subtitle: 'Hiển thị danh mục cho khách hàng',
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            _buildSwitch(
              title: 'Cho phép tuỳ chỉnh',
              subtitle: 'Sản phẩm trong danh mục có thể tuỳ biến',
              value: _isCustomizable,
              onChanged: (v) => setState(() => _isCustomizable = v),
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
                        widget.isEditing ? 'Lưu thay đổi' : 'Tạo danh mục',
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
        border: Border.all(color: const Color(0xFFC1C6D7).withValues(alpha: 0.3)),
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
