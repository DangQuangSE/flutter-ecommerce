import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_state.dart';
import 'package:flutter_ecommerce/features/category/presentation/models/category_form_extra.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/management/category_delete_dialog.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/management/category_detail_sheet.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/management/category_management_app_bar.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/management/category_management_list.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/management/category_search_bar.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/management/category_state_views.dart';
import 'package:flutter_ecommerce/features/category/presentation/widgets/management/category_tree_sheet.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CategoryCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CategoryCubit get _cubit => context.read<CategoryCubit>();

  void _openForm({CategoryEntity? category}) {
    final loaded = _cubit.state;
    final parents =
        loaded is CategoryLoaded ? loaded.categories : <CategoryEntity>[];
    context.pushNamed(
      AppRoutes.adminCategoryForm,
      extra: CategoryFormExtra(
        cubit: _cubit,
        category: category,
        parents: parents,
      ),
    );
  }

  Future<void> _confirmDelete(CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CategoryDeleteDialog(category: category),
    );

    if (confirmed != true || category.id == null) return;
    final error = await _cubit.delete(category.id!);
    if (!mounted) return;
    _showSnack(
      error ?? AppStrings.adminCategoryDeleted,
      isError: error != null,
    );
  }

  Future<void> _toggle(CategoryEntity category) async {
    if (category.id == null) return;
    final error =
        await _cubit.toggleStatus(category.id!, isActive: !category.isActive);
    if (!mounted) return;
    if (error != null) _showSnack(error, isError: true);
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnackBar.show(
      context,
      message: message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.success,
    );
  }

  void _showDetail(CategoryEntity category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusRound)),
      ),
      builder: (_) => FutureBuilder<CategoryEntity?>(
        future: (category.slug != null && category.slug!.isNotEmpty)
            ? _cubit.fetchDetail(category.slug!)
            : Future.value(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 180,
              child: AppLoadingView(),
            );
          }

          return CategoryDetailSheet(category: snapshot.data ?? category);
        },
      ),
    );
  }

  void _showTree() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusRound)),
      ),
      builder: (_) => CategoryTreeSheet(treeFuture: _cubit.fetchTree()),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _cubit.load(search: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CategoryManagementAppBar(onOpenTree: _showTree),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.adminCatalogAdd),
      ),
      body: Column(
        children: [
          CategorySearchBar(
            controller: _searchController,
            onSubmitted: (value) => _cubit.load(search: value),
            onChanged: () => setState(() {}),
            onClear: _clearSearch,
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                return switch (state) {
                  CategoryLoading() => const CategoryLoadingView(),
                  CategoryError(:final message) => CategoryErrorView(
                      message: message,
                      onRetry: _cubit.load,
                    ),
                  CategoryLoaded(:final categories) when categories.isEmpty =>
                    const CategoryEmptyView(),
                  CategoryLoaded() => CategoryManagementList(
                      state: state,
                      onRefresh: _cubit.refresh,
                      onOpenDetail: _showDetail,
                      onEdit: (category) => _openForm(category: category),
                      onDelete: _confirmDelete,
                      onToggle: _toggle,
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
