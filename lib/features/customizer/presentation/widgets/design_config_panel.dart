import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -2))],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'TÙY CHỈNH THIẾT KẾ',
              style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Tự tay thiết kế áo thi đấu đẳng cấp cao. Tên, số áo và logo tùy chỉnh theo ý bạn.',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            _buildMaterialSection(),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            _buildLogoUploadSection(),
            const SizedBox(height: 24),
            LayerEditor(
              layers: layers,
              activeLayerId: activeLayerId,
              onLayerActivated: onLayerActivated,
              onLayerDeleted: onLayerDeleted,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CHẤT LIỆU IN ẤN',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        MaterialCard(
          title: 'In chuyển nhiệt',
          priceAdd: '+30.000 ₫',
          desc: 'Bền màu, phẳng mịn, phù hợp thiết kế nhiều màu sắc phức tạp.',
          isSelected: printMethod == 'In chuyển nhiệt',
          onTap: () => onPrintMethodChanged('In chuyển nhiệt'),
        ),
        const SizedBox(height: 10),
        MaterialCard(
          title: 'Decal phản quang',
          priceAdd: '+50.000 ₫',
          desc: 'Màu sắc nổi bật, độ bền cao, phù hợp in tên và số áo phát sáng.',
          isSelected: printMethod == 'Decal phản quang',
          onTap: () => onPrintMethodChanged('Decal phản quang'),
        ),
      ],
    );
  }

  Widget _buildLogoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('TẢI LÊN LOGO CỦA BẠN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onUploadLogo,
          child: Container(
            height: 98,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primary.withValues(alpha: 0.02),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 28),
                const SizedBox(height: 6),
                Text('NHẤN ĐỂ TẢI ẢNH LÊN', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('PNG, JPG, SVG (Tối đa 5MB)', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
