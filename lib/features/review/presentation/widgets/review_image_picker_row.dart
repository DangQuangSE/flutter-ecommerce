import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewImagePickerRow extends StatelessWidget {
  final List<String> imagePaths;
  final int maxImages;
  final VoidCallback onAddPressed;
  final ValueChanged<int> onRemoveAt;

  const ReviewImagePickerRow({
    super.key,
    required this.imagePaths,
    required this.maxImages,
    required this.onAddPressed,
    required this.onRemoveAt,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...List.generate(
              imagePaths.length, (index) => _buildThumbnail(index)),
          if (imagePaths.length < maxImages) _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePaths[index]),
              width: 76,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => onRemoveAt(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddPressed,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined,
                color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 4),
            Text(
              AppStrings.writeReviewAddImage,
              style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
