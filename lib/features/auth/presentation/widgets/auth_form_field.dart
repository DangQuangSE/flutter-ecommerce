import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

class LoginFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isObscurable;
  final VoidCallback? onToggleObscure;
  final bool showError;
  final ValueChanged<String>? onChanged;
  final String? Function(String?) validator;

  const LoginFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isObscurable = false,
    this.onToggleObscure,
    required this.showError,
    this.onChanged,
    required this.validator,
  });

  @override
  State<LoginFormField> createState() => _LoginFormFieldState();
}

class _LoginFormFieldState extends State<LoginFormField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = widget.showError
        ? AppColors.error
        : (_isFocused ? AppColors.primary : AppColors.textSecondaryLight);

    final prefixIconColor = widget.showError
        ? AppColors.error
        : (_isFocused ? AppColors.primary : AppColors.textSecondaryLight.withValues(alpha: 0.7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fieldLabelFontSize,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 1.0,
          ),
          child: Text(widget.label.toUpperCase()),
        ),
        SizedBox(height: AppSizes.paddingSm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: [
              BoxShadow(
                color: widget.showError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : (_isFocused
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: widget.onChanged,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLg,
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                fontSize: AppSizes.fontLg,
                color: AppColors.textHint,
              ),
              prefixIcon: AnimatedTheme(
                data: ThemeData(
                  iconTheme: IconThemeData(color: prefixIconColor),
                ),
                child: Icon(
                  widget.prefixIcon,
                  size: AppSizes.iconMd,
                  color: prefixIconColor,
                ),
              ),
              suffixIcon: widget.isObscurable
                  ? IconButton(
                      onPressed: widget.onToggleObscure,
                      icon: Icon(
                        widget.obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: AppSizes.iconMd,
                        color: prefixIconColor,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingSm + 4,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(
                  color: widget.showError
                      ? AppColors.error
                      : AppColors.borderGray.withValues(alpha: 0.6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(
                  color: widget.showError ? AppColors.error : AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: const BorderSide(
                  color: AppColors.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              errorStyle: GoogleFonts.inter(
                fontSize: AppSizes.fontSm,
                color: AppColors.error,
              ),
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}

