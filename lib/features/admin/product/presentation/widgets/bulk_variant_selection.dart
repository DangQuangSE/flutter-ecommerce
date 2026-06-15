part of 'bulk_variant_sheet.dart';

// ── Selection form sections ───────────────────────────────────────────────────

class _SizeGroupDropdown extends StatelessWidget {
  final List<SizeGroupEntity> sizeGroups;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _SizeGroupDropdown({
    required this.sizeGroups,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('1. CHỌN NHÓM SIZE'),
          const SizedBox(height: AppSizes.paddingSm),
          DropdownButtonFormField<int>(
            initialValue: selectedId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: 'Chọn nhóm kích thước',
            ),
            isExpanded: true,
            items: sizeGroups
                .where((g) => g.id != null)
                .map((g) => DropdownMenuItem(value: g.id!, child: Text(g.name)))
                .toList(),
            onChanged: onChanged,
            validator: (v) => v == null ? 'Vui lòng chọn nhóm size' : null,
          ),
        ],
      );
}

class _SizeChipsSection extends StatelessWidget {
  final List<String> sizes;
  final Set<String> selectedSizes;
  final ValueChanged<String> onToggle;

  const _SizeChipsSection({
    required this.sizes,
    required this.selectedSizes,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('2. TÙY CHỌN KÍCH THƯỚC'),
          const SizedBox(height: AppSizes.paddingSm),
          Wrap(
            spacing: AppSizes.paddingSm,
            runSpacing: AppSizes.paddingSm,
            children: sizes.map((size) {
              final selected = selectedSizes.contains(size);
              return FilterChip(
                label: Text(size),
                selected: selected,
                onSelected: (_) => onToggle(size),
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.divider),
              );
            }).toList(),
          ),
        ],
      );
}

class _ColorCheckboxSection extends StatelessWidget {
  final List<ProductColorEntity> colors;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  const _ColorCheckboxSection({
    required this.colors,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final valid = colors.where((c) => c.id != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('3. CHỌN MÀU SẮC'),
        const SizedBox(height: AppSizes.paddingSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: AppSizes.paddingSm,
            mainAxisSpacing: AppSizes.paddingSm,
          ),
          itemCount: valid.length,
          itemBuilder: (_, i) => _ColorTile(
            color: valid[i],
            selected: selectedIds.contains(valid[i].id!),
            onTap: () => onToggle(valid[i].id!),
          ),
        ),
      ],
    );
  }
}

class _ColorTile extends StatelessWidget {
  final ProductColorEntity color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorTile({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXs),
          decoration: BoxDecoration(
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            color:
                selected ? AppColors.primary.withValues(alpha: 0.06) : null,
          ),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.primary,
              ),
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(right: AppSizes.paddingXs + 2),
                decoration: BoxDecoration(
                  color: _hexColor(color.hexCode),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider),
                ),
              ),
              Expanded(
                child: Text(
                  color.name,
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    color:
                        selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
}

class _DefaultValuesSection extends StatelessWidget {
  final TextEditingController originalPriceCtrl;
  final TextEditingController salePriceCtrl;
  final TextEditingController stockCtrl;

  const _DefaultValuesSection({
    required this.originalPriceCtrl,
    required this.salePriceCtrl,
    required this.stockCtrl,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('4. THÔNG SỐ BIẾN THỂ MẶC ĐỊNH'),
          const SizedBox(height: AppSizes.paddingSm),
          Row(children: [
            Expanded(
                child: _DefaultPriceField(
                    ctrl: originalPriceCtrl,
                    label: 'Giá gốc *',
                    required: true)),
            const SizedBox(width: AppSizes.paddingSm),
            Expanded(
                child: _DefaultPriceField(
                    ctrl: salePriceCtrl, label: 'Giá bán', required: false)),
            const SizedBox(width: AppSizes.paddingSm),
            Expanded(child: _DefaultStockField(ctrl: stockCtrl)),
          ]),
        ],
      );
}

class _DefaultPriceField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool required;

  const _DefaultPriceField({
    required this.ctrl,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixText: '₫',
        ),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'Bắt buộc';
          if (v != null &&
              v.trim().isNotEmpty &&
              double.tryParse(v.trim()) == null) {
            return 'Không hợp lệ';
          }
          return null;
        },
      );
}

class _DefaultStockField extends StatelessWidget {
  final TextEditingController ctrl;
  const _DefaultStockField({required this.ctrl});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Tồn kho *',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Bắt buộc';
          if (int.tryParse(v.trim()) == null) return 'Số nguyên';
          return null;
        },
      );
}
