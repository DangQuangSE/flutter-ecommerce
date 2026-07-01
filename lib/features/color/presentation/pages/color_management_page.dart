import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/printing_color_entity.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_state.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_state.dart';
import 'package:flutter_ecommerce/features/color/presentation/widgets/color_card.dart';
import 'package:flutter_ecommerce/features/color/presentation/widgets/color_printing_form_sheet.dart';
import 'package:flutter_ecommerce/features/color/presentation/widgets/color_product_form_sheet.dart';
import 'package:flutter_ecommerce/features/color/presentation/widgets/color_state_views.dart';

class ColorManagementPage extends StatefulWidget {
  const ColorManagementPage({super.key});

  @override
  State<ColorManagementPage> createState() => _ColorManagementPageState();
}

class _ColorManagementPageState extends State<ColorManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openProductColorForm({ProductColorEntity? color}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusRound),
        ),
      ),
      builder: (_) => ColorProductFormSheet(
        color: color,
        onSubmit: (entity) {
          if (color == null) {
            context.read<ProductColorCubit>().createColor(entity);
          } else {
            context.read<ProductColorCubit>().updateColor(color.id!, entity);
          }
        },
      ),
    );
  }

  void _openPrintingColorForm({PrintingColorEntity? color}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusRound),
        ),
      ),
      builder: (_) => ColorPrintingFormSheet(
        color: color,
        onSubmit: (entity) {
          if (color == null) {
            context.read<PrintingColorCubit>().createColor(entity);
          } else {
            context.read<PrintingColorCubit>().updateColor(color.id!, entity);
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteProductColor(ProductColorEntity color) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.adminColorDeleteProductTitle,
      message: AppStrings.adminColorDeleteProductBody(color.name),
      confirmLabel: AppStrings.delete,
    );
    if (!confirmed || !mounted || color.id == null) return;
    context.read<ProductColorCubit>().deleteColor(color.id!);
  }

  Future<void> _confirmDeletePrintingColor(PrintingColorEntity color) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.adminColorDeletePrintingTitle,
      message: AppStrings.adminColorDeletePrintingBody(color.name),
      confirmLabel: AppStrings.delete,
    );
    if (!confirmed || !mounted || color.id == null) return;
    context.read<PrintingColorCubit>().deleteColor(color.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.adminColorManagementTitle,
          style: GoogleFonts.lexend(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.fontXxl,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.lexend(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: AppStrings.adminColorProductTab),
            Tab(text: AppStrings.adminColorPrintingTab),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _openProductColorForm();
              } else {
                _openPrintingColorForm();
              }
            },
            icon: const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProductColorsTab(
            onEdit: (color) => _openProductColorForm(color: color),
            onDelete: _confirmDeleteProductColor,
          ),
          _PrintingColorsTab(
            onEdit: (color) => _openPrintingColorForm(color: color),
            onDelete: _confirmDeletePrintingColor,
          ),
        ],
      ),
    );
  }
}

class _ProductColorsTab extends StatelessWidget {
  final ValueChanged<ProductColorEntity> onEdit;
  final ValueChanged<ProductColorEntity> onDelete;

  const _ProductColorsTab({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductColorCubit, ProductColorState>(
      listener: (context, state) {
        if (state is ProductColorLoaded && state.message != null) {
          AppSnackBar.show(
            context,
            message: state.message!,
            type: AppSnackBarType.success,
          );
        } else if (state is ProductColorError) {
          AppSnackBar.show(
            context,
            message: state.message,
            type: AppSnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is ProductColorLoading) return const ColorLoadingView();
        if (state is ProductColorLoaded) {
          if (state.colors.isEmpty) {
            return const ColorEmptyView(
              message: AppStrings.adminColorProductEmpty,
            );
          }
          return _ProductColorGrid(
            colors: state.colors,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }
        return const ColorErrorView(
          message: AppStrings.adminColorProductError,
        );
      },
    );
  }
}

class _ProductColorGrid extends StatelessWidget {
  final List<ProductColorEntity> colors;
  final ValueChanged<ProductColorEntity> onEdit;
  final ValueChanged<ProductColorEntity> onDelete;

  const _ProductColorGrid({
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return ColorCard(
          name: color.name,
          hexCode: color.hexCode,
          onEdit: () => onEdit(color),
          onDelete: () => onDelete(color),
        );
      },
    );
  }
}

class _PrintingColorsTab extends StatelessWidget {
  final ValueChanged<PrintingColorEntity> onEdit;
  final ValueChanged<PrintingColorEntity> onDelete;

  const _PrintingColorsTab({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrintingColorCubit, PrintingColorState>(
      listener: (context, state) {
        if (state is PrintingColorLoaded && state.message != null) {
          AppSnackBar.show(
            context,
            message: state.message!,
            type: AppSnackBarType.success,
          );
        } else if (state is PrintingColorError) {
          AppSnackBar.show(
            context,
            message: state.message,
            type: AppSnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is PrintingColorLoading) return const ColorLoadingView();
        if (state is PrintingColorLoaded) {
          if (state.colors.isEmpty) {
            return const ColorEmptyView(
              message: AppStrings.adminColorPrintingEmpty,
            );
          }
          return _PrintingColorGrid(
            colors: state.colors,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }
        return const ColorErrorView(
          message: AppStrings.adminColorPrintingError,
        );
      },
    );
  }
}

class _PrintingColorGrid extends StatelessWidget {
  final List<PrintingColorEntity> colors;
  final ValueChanged<PrintingColorEntity> onEdit;
  final ValueChanged<PrintingColorEntity> onDelete;

  const _PrintingColorGrid({
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return ColorCard(
          name: color.name,
          hexCode: color.hexCode,
          isActive: color.isActive,
          onToggleActive: (value) {
            if (color.id != null) {
              context
                  .read<PrintingColorCubit>()
                  .toggleColorStatus(color.id!, value);
            }
          },
          onEdit: () => onEdit(color),
          onDelete: () => onDelete(color),
        );
      },
    );
  }
}
