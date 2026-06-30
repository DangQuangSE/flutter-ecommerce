import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class CategorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onChanged;
  final VoidCallback onClear;

  const CategorySearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        onSubmitted: (value) => onSubmitted(value.trim()),
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: 'Tìm danh mục...',
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: onClear,
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  OutlineInputBorder _border({
    Color color = AppColors.divider,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
