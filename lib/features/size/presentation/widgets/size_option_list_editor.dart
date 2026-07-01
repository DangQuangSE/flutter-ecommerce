import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_option_draft.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_option_editor_row.dart';

class SizeOptionListEditor extends StatelessWidget {
  final List<SizeOptionDraft> drafts;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int index, SizeOptionDraft updated) onChanged;

  const SizeOptionListEditor({
    super.key,
    required this.drafts,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.adminSizeGroupSizeListLabel,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        AppSizes.spacingSm,
        ...List.generate(drafts.length, (index) {
          return SizeOptionEditorRow(
            key: ValueKey(index),
            draft: drafts[index],
            onChanged: (updated) => onChanged(index, updated),
            onRemove: () => onRemove(index),
          );
        }),
        AppSizes.spacingXs,
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(AppStrings.adminSizeGroupAddSize),
        ),
      ],
    );
  }
}
