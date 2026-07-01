import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final String? query;
  final EdgeInsetsGeometry padding;

  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onClear,
    this.onChanged,
    this.onSubmitted,
    this.query,
    this.padding = const EdgeInsets.fromLTRB(
      AppSizes.paddingMd,
      AppSizes.paddingSm + AppSizes.paddingXs,
      AppSizes.paddingMd,
      AppSizes.paddingSm,
    ),
  });

  bool get _hasQuery => (query ?? controller.text).isNotEmpty;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted == null
              ? null
              : (value) => onSubmitted!(value.trim()),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: AppSizes.fontLg,
              color: AppColors.textHint,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: AppSizes.iconMd,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _hasQuery
                ? IconButton(
                    tooltip: AppStrings.clearSearch,
                    icon:
                        const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                    onPressed: onClear,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingSm + AppSizes.paddingXs),
            enabledBorder: _border(AppColors.divider),
            focusedBorder: _border(AppColors.primary, width: 1.5),
            border: _border(AppColors.divider),
          ),
        ),
      );

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(color: color, width: width),
      );
}
