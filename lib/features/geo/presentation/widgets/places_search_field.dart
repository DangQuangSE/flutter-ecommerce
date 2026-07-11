import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// Debounced address input that drives Google Places autocomplete. It is a
/// dumb, reusable field — the parent renders suggestions from the cubit state
/// (see [PlacesSuggestionList]) and reacts to [onSearch].
class PlacesSearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final bool isSearching;

  const PlacesSearchField({
    super.key,
    required this.controller,
    required this.onSearch,
    this.isSearching = false,
  });

  @override
  State<PlacesSearchField> createState() => _PlacesSearchFieldState();
}

class _PlacesSearchFieldState extends State<PlacesSearchField> {
  static const Duration _debounce = Duration(milliseconds: 500);
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => widget.onSearch(value));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: AppStrings.adminLocationSearchHint,
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon: widget.isSearching
            ? const Padding(
                padding: EdgeInsets.all(AppSizes.paddingMd),
                child: SizedBox(
                  width: AppSizes.iconSm,
                  height: AppSizes.iconSm,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingMd,
        ),
      ),
    );
  }
}
