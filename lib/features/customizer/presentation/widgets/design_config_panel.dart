import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/material_card.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/layer_editor.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/text_layer_editor.dart';

class DesignConfigPanel extends StatelessWidget {
  final String printMethod;
  final ValueChanged<String> onPrintMethodChanged;
  final DesignLayer? activeLayer;
  final TextEditingController textController;
  final List<String> fontsList;
  final List<Color> presetColors;
  final TextStyle Function(String font) getFontFamily;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onFontChanged;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onCustomColorTap;
  final ValueChanged<double> onFontSizeChanged;
  final VoidCallback onAddLayer;
  final VoidCallback onUploadLogo;
  final List<DesignLayer> layers;
  final String? activeLayerId;
  final ValueChanged<DesignLayer> onLayerActivated;
  final void Function(int index, String id) onLayerDeleted;
  final List<PrintingMaterialEntity>? materials;

  const DesignConfigPanel({
    super.key,
    required this.printMethod,
    required this.onPrintMethodChanged,
    required this.activeLayer,
    required this.textController,
    required this.fontsList,
    required this.presetColors,
    required this.getFontFamily,
    required this.onTextChanged,
    required this.onFontChanged,
    required this.onColorSelected,
    required this.onCustomColorTap,
    required this.onFontSizeChanged,
    required this.onAddLayer,
    required this.onUploadLogo,
    required this.layers,
    required this.activeLayerId,
    required this.onLayerActivated,
    required this.onLayerDeleted,
    this.materials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 16, offset: Offset(0, -2))
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'TÙY CHỈNH THIẾT KẾ',
              style: GoogleFonts.lexend(
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary),
            ),
            AppSizes.spacingXs,
            Text(
              'Tự tay thiết kế áo thi đấu đẳng cấp cao. Tên, số áo và logo tùy chỉnh theo ý bạn.',
              style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                  height: 1.4),
            ),
            AppSizes.spacingLg,
            _buildMaterialSection(),
            AppSizes.spacingLg,
            TextLayerEditor(
              activeLayer: activeLayer,
              textController: textController,
              fontsList: fontsList,
              getFontFamily: getFontFamily,
              presetColors: presetColors,
              onTextChanged: onTextChanged,
              onFontChanged: onFontChanged,
              onColorSelected: onColorSelected,
              onCustomColorTap: onCustomColorTap,
              onFontSizeChanged: onFontSizeChanged,
              onAddLayer: onAddLayer,
            ),
            AppSizes.spacingLg,
            _buildLogoUploadSection(),
            AppSizes.spacingLg,
            LayerEditor(
              layers: layers,
              activeLayerId: activeLayerId,
              onLayerActivated: onLayerActivated,
              onLayerDeleted: onLayerDeleted,
            ),
            const SizedBox(height: AppSizes.paddingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialSection() {
    final list = materials;
    if (list == null || list.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'CHẤT LIỆU IN ẤN',
            style: GoogleFonts.inter(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          AppSizes.spacingSm,
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: AppSizes.paddingLg + 4,
                width: AppSizes.paddingLg + 4,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CHẤT LIỆU IN ẤN',
          style: GoogleFonts.inter(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary),
        ),
        AppSizes.spacingSm,
        ...list.map((m) {
          final isSelected =
              printMethod.toLowerCase() == m.name.toLowerCase() ||
                  m.name.toLowerCase().contains(printMethod.toLowerCase()) ||
                  printMethod.toLowerCase().contains(m.name.toLowerCase());
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingSm + 2),
            child: MaterialCard(
              title: m.name,
              priceAdd: '+${_formatPrice(m.basePrice)}',
              desc: m.description,
              isSelected: isSelected,
              onTap: () => onPrintMethodChanged(m.name),
            ),
          );
        }),
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

  Widget _buildLogoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('TẢI LÊN LOGO CỦA BẠN',
            style: GoogleFonts.inter(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        AppSizes.spacingSm,
        GestureDetector(
          onTap: onUploadLogo,
          child: Container(
            height: 98,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              color: AppColors.primary.withValues(alpha: 0.02),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined,
                    color: AppColors.primary, size: AppSizes.iconLg),
                const SizedBox(height: AppSizes.paddingXs + 2),
                Text('NHẤN ĐỂ TẢI ẢNH LÊN',
                    style: GoogleFonts.inter(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                AppSizes.spacingXs,
                Text('PNG, JPG, SVG (Tối đa 5MB)',
                    style: GoogleFonts.inter(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
