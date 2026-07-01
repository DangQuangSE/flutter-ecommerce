import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

OutlineInputBorder addressInputBorder(Color color, [double width = 1]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );

class AddressFieldLabel extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;
  final String? optionalHint;

  const AddressFieldLabel({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = true,
    this.optionalHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            if (!isRequired && optionalHint != null) ...[
              SizedBox(width: 6),
              Text(
                optionalHint!,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ],
        ),
        SizedBox(height: 6),
        child,
      ],
    );
  }
}

class AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AddressTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textHint),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: AppColors.textSecondary)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: addressInputBorder(const Color(0xFFE5E7EB)),
        enabledBorder: addressInputBorder(const Color(0xFFE5E7EB)),
        focusedBorder: addressInputBorder(AppColors.primary, 1.6),
        errorBorder: addressInputBorder(Colors.red, 1.2),
        focusedErrorBorder: addressInputBorder(Colors.red, 1.6),
      ),
      validator: validator,
    );
  }
}
