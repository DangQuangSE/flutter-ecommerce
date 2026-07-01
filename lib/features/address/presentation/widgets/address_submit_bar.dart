import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressSubmitBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onSubmit;

  const AddressSubmitBar({
    super.key,
    required this.isEditing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final isSubmitting = state is AddressLoaded && state.isSubmitting;
        return Container(
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingMd,
            AppSizes.radiusLg,
            AppSizes.paddingMd,
            MediaQuery.of(context).padding.bottom + AppSizes.radiusLg,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: SizedBox(
            height: AppSizes.buttonMinHeight,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              child: isSubmitting
                  ? const AppLoadingView(
                      size: AppSizes.fontHeading,
                      color: AppColors.white,
                    )
                  : Text(
                      isEditing
                          ? AppStrings.addressUpdate
                          : AppStrings.addressSave,
                      style: GoogleFonts.lexend(
                        fontSize: AppSizes.submitButtonFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
