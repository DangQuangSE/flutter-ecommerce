import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingMd,
        AppSizes.paddingSm,
        AppSizes.paddingMd,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.radiusLg,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _AttachmentButton(),
            Expanded(
              child: _MessageField(
                controller: controller,
                onSend: onSend,
              ),
            ),
            SizedBox(width: AppSizes.radiusMd),
            _SendButton(onSend: onSend),
          ],
        ),
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppSnackBar.show(
          context,
          message: AppStrings.chatAttachmentMessage,
          type: AppSnackBarType.info,
        );
      },
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.only(right: AppSizes.radiusMd),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.add_rounded,
          color: AppColors.primary,
          size: AppSizes.paddingXl,
        ),
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageField({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF3F3F8),
        borderRadius: BorderRadius.circular(AppSizes.paddingXl),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      constraints: BoxConstraints(minHeight: AppSizes.buttonMinHeight),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: AppStrings.chatMessageHint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSizes.radiusMd),
                isDense: true,
              ),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.text += ' 😊';
            },
            child: Icon(
              Icons.sentiment_satisfied_alt_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onSend;

  const _SendButton({required this.onSend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSend,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: AppSizes.fontXxl,
        ),
      ),
    );
  }
}
