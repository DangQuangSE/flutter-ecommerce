import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_option_draft.dart';

class SizeOptionEditorRow extends StatefulWidget {
  final SizeOptionDraft draft;
  final ValueChanged<SizeOptionDraft> onChanged;
  final VoidCallback onRemove;

  const SizeOptionEditorRow({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<SizeOptionEditorRow> createState() => _SizeOptionEditorRowState();
}

class _SizeOptionEditorRowState extends State<SizeOptionEditorRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _orderCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.draft.name);
    _orderCtrl = TextEditingController(
      text: widget.draft.displayOrder.toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(
      widget.draft.copyWith(
        name: _nameCtrl.text,
        displayOrder: int.tryParse(_orderCtrl.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSm),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _nameCtrl,
              onChanged: (_) => _notifyChanged(),
              decoration: const InputDecoration(
                hintText: AppStrings.adminSizeGroupSizeNameHint,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm),
          SizedBox(
            width: AppSizes.iconXl,
            child: TextFormField(
              controller: _orderCtrl,
              onChanged: (_) => _notifyChanged(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: AppStrings.adminSizeGroupSizeOrderHint,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: AppSizes.paddingSm, vertical: 10),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: AppColors.error,
            ),
            tooltip: AppStrings.delete,
          ),
        ],
      ),
    );
  }
}
