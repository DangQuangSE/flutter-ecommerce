import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class StarRatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const StarRatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          onPressed: () => onChanged(starValue),
          icon: Icon(
            starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.accent,
            size: 36,
          ),
        );
      }),
    );
  }
}
