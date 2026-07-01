import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';

class ColorProductFormSheet extends StatefulWidget {
  final ProductColorEntity? color;
  final ValueChanged<ProductColorEntity> onSubmit;

  const ColorProductFormSheet({
    super.key,
    this.color,
    required this.onSubmit,
  });

  @override
  State<ColorProductFormSheet> createState() => _ColorProductFormSheetState();
}

class _ColorProductFormSheetState extends State<ColorProductFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _hexController;

  bool get _isEdit => widget.color != null;

  static const List<Map<String, String>> _presets = [
    {'name': 'Đen Jet', 'hex': '#000000'},
    {'name': 'Trắng Chalk', 'hex': '#FFFFFF'},
    {'name': 'Đỏ Crimson', 'hex': '#DC143C'},
    {'name': 'Xanh Cobalt', 'hex': '#0047AB'},
    {'name': 'Vàng Neon', 'hex': '#E0FF00'},
    {'name': 'Cam Hổ Phách', 'hex': '#FFBF00'},
    {'name': 'Lục Emerald', 'hex': '#50C878'},
    {'name': 'Tím Lavender', 'hex': '#E6E6FA'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.color?.name ?? '');
    _hexController = TextEditingController(text: widget.color?.hexCode ?? '#');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  static Color _hexToColor(String hex) {
    try {
      String clean = hex.replaceAll('#', '').trim();
      if (clean.length == 3) clean = clean.split('').map((c) => '$c$c').join();
      if (clean.length == 6) clean = 'FF$clean';
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  void _openColorPicker() {
    final current = _hexToColor(_hexController.text);
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl)),
        title: Text(
          AppStrings.adminColorPickerTitle,
          style: GoogleFonts.lexend(
              fontWeight: FontWeight.w700, fontSize: AppSizes.fontXl),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: (color) {
              final hex =
                  '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
              setState(() => _hexController.text = hex);
            },
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text(
              AppStrings.adminColorPickerDone,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final hex = _hexController.text.trim().toUpperCase();

    if (name.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppStrings.adminColorProductNameRequired,
        type: AppSnackBarType.error,
      );
      return;
    }

    final regex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    if (!regex.hasMatch(hex)) {
      AppSnackBar.show(
        context,
        message: AppStrings.adminColorHexInvalidFull,
        type: AppSnackBarType.error,
      );
      return;
    }

    widget.onSubmit(ProductColorEntity(
      id: widget.color?.id,
      name: name,
      hexCode: hex,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.paddingLg,
        right: AppSizes.paddingLg,
        top: AppSizes.paddingXl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingXl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEdit
                      ? AppStrings.adminColorProductFormEditTitle
                      : AppStrings.adminColorProductFormCreateTitle,
                  style: GoogleFonts.lexend(
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 12),
            const _FormLabel(AppStrings.adminColorProductNameLabel),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: AppStrings.adminColorProductNameHint,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            AppSizes.spacingMd,
            const _FormLabel(AppStrings.adminColorHexLabel),
            TextField(
              controller: _hexController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: AppStrings.adminColorProductHexHint,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: IconButton(
                  icon: Icon(Icons.color_lens_outlined,
                      color: AppColors.primary),
                  onPressed: _openColorPicker,
                ),
              ),
            ),
            AppSizes.spacingMd,
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _hexToColor(_hexController.text),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  AppStrings.adminColorPreviewLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            AppSizes.spacingMd,
            const _FormLabel(AppStrings.adminColorPresetsLabel),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                final presetColor = _hexToColor(preset['hex']!);
                return GestureDetector(
                  onTap: () => setState(() {
                    _nameController.text = preset['name']!;
                    _hexController.text = preset['hex']!;
                  }),
                  child: Chip(
                    backgroundColor: presetColor.withValues(alpha: 0.12),
                    side: BorderSide(color: presetColor.withValues(alpha: 0.3)),
                    avatar:
                        CircleAvatar(radius: 8, backgroundColor: presetColor),
                    label: Text(
                      preset['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            AppSizes.spacingLg,
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Text(
                _isEdit
                    ? AppStrings.adminColorSaveChanges
                    : AppStrings.adminColorCreateProductAction,
                style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
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
