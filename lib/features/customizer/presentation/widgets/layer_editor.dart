import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';

class LayerEditor extends StatelessWidget {
  final List<DesignLayer> layers;
  final String? activeLayerId;
  final ValueChanged<DesignLayer> onLayerActivated;
  final void Function(int index, String id) onLayerDeleted;

  const LayerEditor({
    super.key,
    required this.layers,
    required this.activeLayerId,
    required this.onLayerActivated,
    required this.onLayerDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'LỚP THIẾT KẾ HOẠT ĐỘNG',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (layers.isEmpty)
          Text(
            'Chưa có lớp thiết kế nào được tạo.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: layers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final layer = layers[index];
              final bool isActive = activeLayerId == layer.id;
              return GestureDetector(
                onTap: () => onLayerActivated(layer),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFFF3F3F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        layer.type == LayerType.text ? Icons.text_fields_rounded : Icons.image_rounded,
                        color: isActive ? AppColors.primary : AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              layer.type == LayerType.text ? layer.text : 'Logo của bạn',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              layer.type == LayerType.text
                                  ? '${layer.font} | ${layer.fontSize.toInt()}px'
                                  : 'Ảnh Tải Lên',
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                        onPressed: () => onLayerDeleted(index, layer.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
