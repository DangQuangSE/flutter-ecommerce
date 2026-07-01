import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/forms/app_search_field.dart';

class BrandSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const BrandSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => AppSearchField(
        controller: controller,
        hintText: AppStrings.adminBrandSearchHint,
        onChanged: onChanged,
        onClear: onClear,
      );
}
