import 'package:flutter/material.dart';

class ProductDetailDivider extends StatelessWidget {
  const ProductDetailDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
