import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// Bottom sheet for composing/editing the shop's reply to a single review.
/// Returns the submitted text via [Navigator.pop], or `null` if cancelled.
class AdminReviewReplySheet extends StatefulWidget {
  final String? initialReply;

  const AdminReviewReplySheet({super.key, this.initialReply});

  @override
  State<AdminReviewReplySheet> createState() => _AdminReviewReplySheetState();
}

class _AdminReviewReplySheetState extends State<AdminReviewReplySheet> {
  late final _controller = TextEditingController(text: widget.initialReply);
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = AppStrings.adminReviewReplyRequired);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.adminReviewReplySheetTitle,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppStrings.adminReviewReplyHint,
              errorText: _errorText,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(
                AppStrings.adminReviewReplySubmit,
                style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
