import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';

/// A single review row in the admin review list — shows the reviewer,
/// product, rating, comment and the shop's reply (if any). View + reply
/// only: there is intentionally no hide/delete action here.
class AdminReviewTile extends StatelessWidget {
  final ReviewEntity review;
  final VoidCallback onReply;

  const AdminReviewTile({
    super.key,
    required this.review,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(review: review),
          SizedBox(height: 8),
          _RatingRow(rating: review.rating),
          if (review.productName.isNotEmpty) ...[
            SizedBox(height: 6),
            _ProductChip(productName: review.productName),
          ],
          SizedBox(height: 8),
          Text(
            review.comment,
            style:
                GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
          ),
          SizedBox(height: 10),
          if (review.replyComment != null && review.replyComment!.isNotEmpty)
            _ReplyBox(replyComment: review.replyComment!),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onReply,
              child: Text(
                review.replyComment == null || review.replyComment!.isEmpty
                    ? AppStrings.adminReviewReplyAction
                    : AppStrings.adminReviewEditReplyAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ReviewEntity review;

  const _Header({required this.review});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: review.userAvatar == null
              ? null
              : CachedNetworkImageProvider(review.userAvatar!),
          child: review.userAvatar == null
              ? Icon(Icons.person_rounded,
                  size: 18, color: AppColors.primary)
              : null,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(review.createdAt),
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final int rating;

  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: AppColors.accent,
        );
      }),
    );
  }
}

class _ProductChip extends StatelessWidget {
  final String productName;

  const _ProductChip({required this.productName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        productName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ReplyBox extends StatelessWidget {
  final String replyComment;

  const _ReplyBox({required this.replyComment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.adminReviewReplyLabel,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            replyComment,
            style:
                GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
