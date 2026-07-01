import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/write_review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/write_review_state.dart';
import 'package:flutter_ecommerce/features/review/presentation/widgets/review_image_picker_row.dart';
import 'package:flutter_ecommerce/features/review/presentation/widgets/star_rating_selector.dart';

class WriteReviewArgs {
  final int orderItemId;
  final String productName;

  const WriteReviewArgs({required this.orderItemId, required this.productName});
}

class WriteReviewPage extends StatefulWidget {
  final WriteReviewArgs args;

  const WriteReviewPage({super.key, required this.args});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  static const int _maxImages = 5;

  final _commentController = TextEditingController();
  int _rating = 0;
  final List<XFile> _pickedImages = [];
  bool _isPicking = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_isPicking) return;
    _isPicking = true;
    final remaining = _maxImages - _pickedImages.length;
    final files = await ImagePicker().pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    _isPicking = false;
    if (!mounted || files.isEmpty) return;

    if (files.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.writeReviewMaxImages(_maxImages)),
        backgroundColor: AppColors.warning,
      ));
    }
    setState(() => _pickedImages.addAll(files.take(remaining)));
  }

  void _removeImageAt(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  void _onSubmitPressed() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppStrings.writeReviewRatingRequired),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppStrings.writeReviewCommentRequired),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    context.read<WriteReviewCubit>().submit(
          orderItemId: widget.args.orderItemId,
          rating: _rating,
          comment: _commentController.text.trim(),
          imagePaths: _pickedImages.map((file) => file.path).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(AppStrings.writeReviewTitle,
            style:
                GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: BlocConsumer<WriteReviewCubit, WriteReviewState>(
        listener: (context, state) {
          if (state is WriteReviewSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(AppStrings.writeReviewSubmitSuccess),
              backgroundColor: AppColors.success,
            ));
            context.pop(true);
          } else if (state is WriteReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is WriteReviewSubmitting;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProductName(),
                SizedBox(height: 20),
                _buildRatingSection(),
                SizedBox(height: 20),
                _buildCommentSection(),
                SizedBox(height: 20),
                _buildImageSection(),
                SizedBox(height: 24),
                _buildSubmitButton(isSubmitting),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      widget.args.productName,
      style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        Text(
          AppStrings.writeReviewRatingLabel,
          textAlign: TextAlign.center,
          style:
              GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        SizedBox(height: 8),
        StarRatingSelector(
            rating: _rating,
            onChanged: (value) => setState(() => _rating = value)),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.writeReviewCommentLabel,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppStrings.writeReviewCommentHint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderGray),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return ReviewImagePickerRow(
      imagePaths: _pickedImages.map((file) => file.path).toList(),
      maxImages: _maxImages,
      onAddPressed: _pickImages,
      onRemoveAt: _removeImageAt,
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    return ElevatedButton(
      onPressed: isSubmitting ? null : _onSubmitPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isSubmitting
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Text(
              AppStrings.writeReviewSubmit,
              style:
                  GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800),
            ),
    );
  }
}
