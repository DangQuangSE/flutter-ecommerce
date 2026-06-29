part of 'color_management_page.dart';

extension _ColorManagementTabs on _ColorManagementPageState {
  // ── Tab 1: Product Colors ──────────────────────────────────────────────────
  Widget _buildProductColorsTab() {
    return BlocConsumer<ProductColorCubit, ProductColorState>(
      listener: (context, state) {
        if (state is ProductColorLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ProductColorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProductColorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductColorLoaded) {
          final colors = state.colors;
          if (colors.isEmpty) {
            return _buildEmptyState('Chưa có màu sản phẩm nào.');
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return _buildColorCard(
                context: context,
                name: color.name,
                hexCode: color.hexCode,
                onEdit: () => _openProductColorForm(context, color: color),
                onDelete: () => _confirmDeleteProductColor(context, color),
              );
            },
          );
        }

        return const Center(child: Text('Lỗi tải màu sản phẩm.'));
      },
    );
  }

  // ── Tab 2: Printing Colors ──────────────────────────────────────────────────
  Widget _buildPrintingColorsTab() {
    return BlocConsumer<PrintingColorCubit, PrintingColorState>(
      listener: (context, state) {
        if (state is PrintingColorLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is PrintingColorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PrintingColorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PrintingColorLoaded) {
          final colors = state.colors;
          if (colors.isEmpty) {
            return _buildEmptyState('Chưa có màu in ấn nào.');
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return _buildColorCard(
                context: context,
                name: color.name,
                hexCode: color.hexCode,
                isActive: color.isActive,
                onToggleActive: (val) {
                  if (color.id != null) {
                    context
                        .read<PrintingColorCubit>()
                        .toggleColorStatus(color.id!, val);
                  }
                },
                onEdit: () => _openPrintingColorForm(context, color: color),
                onDelete: () => _confirmDeletePrintingColor(context, color),
              );
            },
          );
        }

        return const Center(child: Text('Lỗi tải màu in ấn.'));
      },
    );
  }
}
