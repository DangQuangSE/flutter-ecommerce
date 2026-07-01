import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/forms/app_search_field.dart';

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
  Widget build(BuildContext context) => AppSearchField(
        controller: controller,
        hintText: AppStrings.adminCategorySearchHint,
        onSubmitted: onSubmitted,
        onChanged: (_) => onChanged(),
        onClear: onClear,
      );
}
