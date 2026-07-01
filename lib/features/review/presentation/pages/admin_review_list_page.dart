import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/admin_review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/admin_review_state.dart';
import 'package:flutter_ecommerce/features/review/presentation/widgets/admin_review_reply_sheet.dart';
import 'package:flutter_ecommerce/features/review/presentation/widgets/admin_review_tile.dart';

/// Admin review management: view all reviews (paginated) and reply.
/// There is no hide/delete capability by design — admins must not be able
/// to suppress genuine, if negative, customer feedback.
class AdminReviewListPage extends StatefulWidget {
  const AdminReviewListPage({super.key});

  @override
  State<AdminReviewListPage> createState() => _AdminReviewListPageState();
}

class _AdminReviewListPageState extends State<AdminReviewListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminReviewCubit>().load();
    });
  }

  AdminReviewCubit get _cubit => context.read<AdminReviewCubit>();

  Future<void> _openReplySheet(int reviewId, String? currentReply) async {
    final reply = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AdminReviewReplySheet(initialReply: currentReply),
    );
    if (reply == null) return;
    final error = await _cubit.reply(reviewId, reply);
    if (!mounted) return;
    _showSnack(error ?? AppStrings.adminReviewReplySuccess,
        isError: error != null);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocBuilder<AdminReviewCubit, AdminReviewState>(
          builder: (context, state) => switch (state) {
            AdminReviewInitial() || AdminReviewLoading() => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            AdminReviewError(:final message) => _buildError(message),
            AdminReviewEmpty() => _buildEmpty(),
            AdminReviewLoaded() => _buildList(state),
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
      title: Text(
        AppStrings.adminReviewsTitle,
        style: GoogleFonts.lexend(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildList(AdminReviewLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _cubit.refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.reviews.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeaderRow(state);
          final review = state.reviews[index - 1];
          return AdminReviewTile(
            review: review,
            onReply: () => _openReplySheet(review.id, review.replyComment),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRow(AdminReviewLoaded state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.adminReviewsCount(state.totalElements),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (state.isMutating)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.reviews_outlined,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              AppStrings.adminReviewsEmptyTitle,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.adminReviewsEmptySubtitle,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.adminReviewsLoadError,
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _cubit.load(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
