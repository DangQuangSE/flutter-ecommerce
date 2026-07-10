import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';

/// Dropdown list of Google Places predictions rendered under the search field.
class PlacesSuggestionList extends StatelessWidget {
  final List<PlaceSuggestion> suggestions;
  final ValueChanged<PlaceSuggestion> onSelected;

  const PlacesSuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  static const double _maxHeight = 240;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      color: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: AppSizes.iconMd,
              ),
              title: Text(
                suggestion.description,
                style: const TextStyle(fontSize: AppSizes.fontLg),
              ),
              onTap: () => onSelected(suggestion),
            );
          },
        ),
      ),
    );
  }
}
