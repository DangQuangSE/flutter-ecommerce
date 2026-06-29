part of 'product_filter_bottom_sheet.dart';

class _BrandSection extends StatelessWidget {
  final List<BrandEntity> brands;
  final bool loading;
  final int? selectedId;
  final void Function(int? id, String? name) onSelect;

  const _BrandSection({
    required this.brands,
    required this.loading,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Thương hiệu'),
        if (loading)
          const Center(child: CircularProgressIndicator(strokeWidth: 2))
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 140),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: brands.map((brand) {
                  final selected = selectedId == brand.id;
                  return GestureDetector(
                    onTap: () {
                      if (brand.id == null) return;
                      if (selectedId == brand.id) {
                        onSelect(null, null);
                      } else {
                        onSelect(brand.id!, brand.name);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        brand.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

class _GenderSection extends StatelessWidget {
  final String? selected;
  final void Function(String? gender) onSelect;

  const _GenderSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = [
      (null, 'Tất cả'),
      ('MALE', 'Nam'),
      ('FEMALE', 'Nữ'),
      ('UNISEX', 'Unisex'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Giới tính'),
        Row(
          children: options.map(((String?, String) opt) {
            final (value, label) = opt;
            final isSelected = selected == value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(value),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

class _ColorSection extends StatelessWidget {
  final String? selected;
  final void Function(String? color) onSelect;

  const _ColorSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Màu sắc'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: productColorMap.entries.map((entry) {
            final isSelected = selected == entry.key;
            return GestureDetector(
              onTap: () => onSelect(selected == entry.key ? null : entry.key),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.value,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }
}
