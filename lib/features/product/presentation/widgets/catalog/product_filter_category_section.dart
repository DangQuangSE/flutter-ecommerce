part of 'product_filter_bottom_sheet.dart';

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<CategoryTreeNode> categories;
  final bool loading;
  final String? error;
  final int? selectedId;
  final Set<int> expandedIds;
  final void Function(int? id, String? name) onSelect;
  final void Function(int id) onToggleExpand;

  const _CategorySection({
    required this.categories,
    required this.loading,
    this.error,
    required this.selectedId,
    required this.expandedIds,
    required this.onSelect,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Danh mục'),
        if (loading)
          const Center(child: CircularProgressIndicator(strokeWidth: 2))
        else if (error != null)
          Text(error!, style: const TextStyle(color: AppColors.error))
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: SingleChildScrollView(
              child: Column(
                children: categories.map((node) {
                  final isExpanded = expandedIds.contains(node.id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          if (node.children.isNotEmpty) {
                            onToggleExpand(node.id);
                          } else if (selectedId == node.id) {
                            onSelect(null, null);
                          } else {
                            onSelect(node.id, node.name);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(node.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: selectedId == node.id
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selectedId == node.id
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    )),
                              ),
                              if (node.children.isNotEmpty)
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              if (selectedId == node.id)
                                const Icon(Icons.check,
                                    size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            children: node.children.map((child) {
                              return InkWell(
                                onTap: () => selectedId == child.id
                                    ? onSelect(null, null)
                                    : onSelect(child.id, child.name),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(child.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: selectedId == child.id
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                              fontWeight: selectedId == child.id
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            )),
                                      ),
                                      if (selectedId == child.id)
                                        const Icon(Icons.check,
                                            size: 14, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
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
