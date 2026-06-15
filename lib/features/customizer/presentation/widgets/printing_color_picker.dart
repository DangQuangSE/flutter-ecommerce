import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class PrintingColorPicker extends StatelessWidget {
  final List<Color> presetColors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onCustomColorTap;

  const PrintingColorPicker({
    super.key,
    required this.presetColors,
    required this.selectedColor,
    required this.onColorSelected,
    required this.onCustomColorTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: presetColors.length + 1,
        itemBuilder: (context, idx) {
          if (idx == presetColors.length) {
            return GestureDetector(
              onTap: onCustomColorTap,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
                ),
                child: const Icon(Icons.colorize_rounded, size: 16, color: Colors.white),
              ),
            );
          }

          final color = presetColors[idx];
          final isSelected = selectedColor?.toARGB32() == color.toARGB32();

          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFC1C6D7).withValues(alpha: 0.5),
                  width: isSelected ? 3.0 : 1.0,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: color == Colors.white ? Colors.black : Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
