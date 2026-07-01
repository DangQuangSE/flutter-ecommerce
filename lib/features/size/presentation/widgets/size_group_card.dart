import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';

class SizeGroupCard extends StatelessWidget {
  final SizeGroupEntity group;
  final VoidCallback onEdit;

  const SizeGroupCard({
    super.key,
    required this.group,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final preview = group.sizes.map((size) => size.name).take(5).join(', ');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingSm,
        ),
        title: Text(
          group.name,
          style: GoogleFonts.inter(
            fontSize: AppSizes.submitButtonFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description != null && group.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  group.description!,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            if (preview.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.paddingXs),
                child: Text(
                  preview + (group.sizes.length > 5 ? '...' : ''),
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMd,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        trailing: _CardActions(group: group, onEdit: onEdit),
      ),
    );
  }
}

class _CardActions extends StatelessWidget {
  final SizeGroupEntity group;
  final VoidCallback onEdit;

  const _CardActions({
    required this.group,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit_rounded,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
          tooltip: AppStrings.edit,
          onPressed: onEdit,
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: AppColors.error,
          ),
          tooltip: AppStrings.delete,
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.adminSizeGroupDeleteTitle,
      message: AppStrings.adminSizeGroupDeleteBody(group.name),
      confirmLabel: AppStrings.delete,
    );
    if (confirmed && context.mounted) {
      context.read<SizeGroupCubit>().deleteSizeGroup(group.id!);
    }
  }
}
