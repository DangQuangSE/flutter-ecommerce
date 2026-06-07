import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_state.dart';
import 'package:flutter_ecommerce/features/category/presentation/pages/category_form_page.dart';

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
    context.read<CategoryCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CategoryCubit get _cubit => context.read<CategoryCubit>();

  /// Pushes the form, re-providing the SAME cubit so mutations refresh this list.
  void _openForm({CategoryEntity? category}) {
    final loaded = _cubit.state;
    final parents =
        loaded is CategoryLoaded ? loaded.categories : <CategoryEntity>[];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _cubit,
          child: CategoryFormPage(category: category, parents: parents),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xoá danh mục',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
        content: Text('Bạn có chắc muốn xoá "${category.name}"?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || category.id == null) return;
    final error = await _cubit.delete(category.id!);
    if (!mounted) return;
    _showSnack(error ?? 'Đã xoá danh mục', isError: error != null);
  }

  Future<void> _toggle(CategoryEntity category) async {
    if (category.id == null) return;
    final error =
        await _cubit.toggleStatus(category.id!, isActive: !category.isActive);
    if (!mounted) return;
    if (error != null) _showSnack(error, isError: true);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ));
  }

  // ── Detail (GET /api/categories/{slug}) ─────────────────────────────────────
  void _showDetail(CategoryEntity category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FutureBuilder<CategoryEntity?>(
        future: (category.slug != null && category.slug!.isNotEmpty)
            ? _cubit.fetchDetail(category.slug!)
            : Future.value(category),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }
          return _detailContent(snap.data ?? category);
        },
      ),
    );
  }

  Widget _detailContent(CategoryEntity c) {
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ),
              Expanded(
                child: Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary)),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(c.name,
              style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          row('ID', '${c.id ?? '—'}'),
          row('Slug', c.slug ?? '—'),
          row('Mô tả', (c.description ?? '').isEmpty ? '—' : c.description!),
          row('Danh mục cha', c.parentId?.toString() ?? 'Không có'),
          row('Thứ tự', c.displayOrder?.toString() ?? '—'),
          row('Trạng thái', c.isActive ? 'Đang hoạt động' : 'Tạm ẩn'),
          row('Tuỳ chỉnh', c.isCustomizable ? 'Có' : 'Không'),
          row('Tạo lúc', c.createdAt?.toString().split('.').first ?? '—'),
          row('Cập nhật', c.updatedAt?.toString().split('.').first ?? '—'),
        ],
      ),
    );
  }

  // ── Tree (GET /api/categories/tree) ─────────────────────────────────────────
  void _showTree() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => FutureBuilder<List<CategoryTreeNode>>(
          future: _cubit.fetchTree(),
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              );
            }
            final nodes = snap.data ?? const <CategoryTreeNode>[];
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text('Cây danh mục',
                    style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                if (nodes.isEmpty)
                  Text('Không có dữ liệu.',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary))
                else
                  ..._treeTiles(nodes, 0),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _treeTiles(List<CategoryTreeNode> nodes, int depth) {
    final widgets = <Widget>[];
    for (final n in nodes) {
      widgets.add(Padding(
        padding: EdgeInsets.only(left: depth * 20.0, top: 6, bottom: 6),
        child: Row(
          children: [
            Icon(
                depth == 0
                    ? Icons.folder_rounded
                    : Icons.subdirectory_arrow_right_rounded,
                size: 18,
                color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(n.name,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            if (n.isCustomizable)
              const Icon(Icons.brush_rounded, size: 13, color: AppColors.accent),
          ],
        ),
      ));
      widgets.addAll(_treeTiles(n.children, depth + 1));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          'Quản lý danh mục',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Xem cây danh mục',
            icon: const Icon(Icons.account_tree_outlined,
                color: AppColors.textPrimary, size: 22),
            onPressed: _showTree,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: Text('Thêm', style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }
                if (state is CategoryError) {
                  return _buildError(state.message);
                }
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) return _buildEmpty();
                  return _buildList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) => _cubit.load(search: value.trim()),
        decoration: InputDecoration(
          hintText: 'Tìm danh mục...',
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _cubit.load(search: '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildList(CategoryLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _cubit.refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: state.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.totalElements} danh mục',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (state.isMutating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                ],
              ),
            );
          }
          return _buildTile(state.categories[index - 1]);
        },
      ),
    );
  }

  Widget _buildTile(CategoryEntity category) {
    return GestureDetector(
      onTap: () => _showDetail(category),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC1C6D7).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                ? Image.network(
                    category.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.category_rounded, color: AppColors.primary),
                  )
                : const Icon(Icons.category_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (category.isCustomizable) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.brush_rounded,
                          size: 14, color: AppColors.accent),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  category.slug ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: category.isActive,
            activeThumbColor: AppColors.success,
            onChanged: (_) => _toggle(category),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') _openForm(category: category);
              if (value == 'delete') _confirmDelete(category);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Sửa')),
              const PopupMenuItem(value: 'delete', child: Text('Xoá')),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Chưa có danh mục nào',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nhấn "Thêm" để tạo danh mục đầu tiên.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Không tải được danh mục',
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _cubit.load(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
