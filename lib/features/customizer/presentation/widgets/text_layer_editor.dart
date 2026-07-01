import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
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
              AppStrings.customizerTextEditorTitle,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: onAddLayer,
              icon: Icon(Icons.add_rounded, size: AppSizes.iconSm),
              label: Text(
                AppStrings.customizerAddLayer,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs + 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        if (activeLayer != null && activeLayer!.type == LayerType.text) ...[
          const _FieldLabel(AppStrings.customizerTextLayerContent),
          SizedBox(height: AppSizes.paddingXs + 2),
          TextField(
            controller: textController,
            onChanged: onTextChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.canvasLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingMd - 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLg - 1,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.paddingMd),
          const _FieldLabel(AppStrings.customizerFont),
          SizedBox(height: AppSizes.paddingXs + 2),
          _FontDropdown(
            activeLayer: activeLayer!,
            fontsList: fontsList,
            getFontFamily: getFontFamily,
            onFontChanged: onFontChanged,
          ),
          SizedBox(height: AppSizes.paddingMd),
          const _FieldLabel(AppStrings.customizerPrintColor),
          SizedBox(height: AppSizes.paddingXs + 6),
          PrintingColorPicker(
            presetColors: presetColors,
            selectedColor: activeLayer?.color,
            onColorSelected: onColorSelected,
            onCustomColorTap: onCustomColorTap,
          ),
          SizedBox(height: AppSizes.paddingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _FieldLabel(AppStrings.customizerFontSize),
              Text(
                '${activeLayer!.fontSize.toInt()}px',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
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
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Text(
              AppStrings.customizerNoTextLayerSelected,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontXs + 1,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _FontDropdown extends StatelessWidget {
  final DesignLayer activeLayer;
  final List<String> fontsList;
  final TextStyle Function(String font) getFontFamily;
  final ValueChanged<String> onFontChanged;

  const _FontDropdown({
    required this.activeLayer,
    required this.fontsList,
    required this.getFontFamily,
    required this.onFontChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.canvasLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: activeLayer.font,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          items: fontsList
              .map(
                (font) => DropdownMenuItem<String>(
                  value: font,
                  child: Text(
                    AppStrings.customizerSportFontLabel(font),
                    style: getFontFamily(font).copyWith(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onFontChanged(value);
          },
        ),
      ),
    );
  }
}
