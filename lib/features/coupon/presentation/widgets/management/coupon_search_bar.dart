import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/forms/app_search_field.dart';

class CouponSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const CouponSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => AppSearchField(
        controller: controller,
        query: query,
        hintText: AppStrings.adminCouponSearchHint,
        onChanged: (value) => onChanged(value.trim()),
        onClear: onClear,
      );
}
