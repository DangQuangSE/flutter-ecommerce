import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/printing_color_picker.dart';

class TextLayerEditor extends StatelessWidget {
  final DesignLayer? activeLayer;
  final TextEditingController textController;
  final List<String> fontsList;
  final TextStyle Function(String font) getFontFamily;
  final List<Color> presetColors;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onFontChanged;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onCustomColorTap;
  final ValueChanged<double> onFontSizeChanged;
  final VoidCallback onAddLayer;

  const TextLayerEditor({
    super.key,
    required this.activeLayer,
    required this.textController,
    required this.fontsList,
    required this.getFontFamily,
    required this.presetColors,
    required this.onTextChanged,
    required this.onFontChanged,
    required this.onColorSelected,
    required this.onCustomColorTap,
    required this.onFontSizeChanged,
    required this.onAddLayer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CHỈNH SỬA CHỮ / SỐ',
              style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            TextButton.icon(
              onPressed: onAddLayer,
              icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
              label: Text('THÊM LỚP MỚI',
                  style: GoogleFonts.inter(
                      fontSize: AppSizes.fontXs + 1,
                      fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (activeLayer != null && activeLayer!.type == LayerType.text) ...[
          Text('NỘI DUNG LỚP CHỮ',
              style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs + 1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingXs + 2),
          TextField(
            controller: textController,
            onChanged: onTextChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.canvasLight,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: AppSizes.paddingMd - 4),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  borderSide: BorderSide.none),
            ),
            style: GoogleFonts.inter(
                fontSize: AppSizes.fontLg - 1,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Text('FONT CHỮ',
              style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs + 1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingXs + 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
            decoration: BoxDecoration(
                color: AppColors.canvasLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: activeLayer!.font,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary),
                items: fontsList
                    .map((font) => DropdownMenuItem<String>(
                          value: font,
                          child: Text('$font (Thể thao)',
                              style: getFontFamily(font).copyWith(
                                  fontSize: AppSizes.fontLg,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) onFontChanged(val);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Text('MÀU SẮC IN',
              style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs + 1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.paddingXs + 6),
          PrintingColorPicker(
            presetColors: presetColors,
            selectedColor: activeLayer?.color,
            onColorSelected: onColorSelected,
            onCustomColorTap: onCustomColorTap,
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CỠ CHỮ',
                  style: GoogleFonts.inter(
                      fontSize: AppSizes.fontXs + 1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              Text('${activeLayer!.fontSize.toInt()}px',
                  style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          Slider(
            value: activeLayer!.fontSize,
            min: 12,
            max: 60,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.canvasLight,
            onChanged: onFontSizeChanged,
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd - 4),
            decoration: BoxDecoration(
                color: AppColors.canvasLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
            child: Text(
              'Chọn hoặc thêm một lớp chữ để bắt đầu chỉnh sửa.',
              style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMd, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
