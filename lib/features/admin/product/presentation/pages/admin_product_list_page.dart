import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/bloc/admin_product_list_bloc.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminProductListBloc>().add(AdminProductListLoadedMore());
    }
  }

  Future<void> _confirmDelete(BuildContext context, int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa sản phẩm "$name"?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('Hủy')),
          TextButton(
              onPressed: () => ctx.pop(true),
              child:
                  const Text('Xóa', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AdminProductListBloc>().add(AdminProductDeleted(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: show search bar / filter sheet
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bloc = context.read<AdminProductListBloc>();
          await context.pushNamed(AppRoutes.adminProductCreate);
          if (context.mounted) {
            bloc.add(AdminProductListRefreshed());
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<AdminProductListBloc, AdminProductListState>(
        listener: (context, state) {
          if (state is AdminProductListFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminProductListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminProductListFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AdminProductListBloc>()
                        .add(AdminProductListLoaded()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (state is AdminProductListSuccess) {
            if (state.totalElements == 0 && state.products.isEmpty) {
              return const Center(child: Text('Không có sản phẩm nào'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AdminProductListBloc>()
                    .add(AdminProductListRefreshed());
              },
              child: ListView.separated(
                controller: _scrollController,
                itemCount:
                    state.products.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final product = state.products[index];
                  return ListTile(
                    leading: product.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: product.thumbnailUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textHint),
                          )
                        : const Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textHint),
                    title: Text(product.name),
                    subtitle: Text(
                        '${product.brandName} • ${product.status.name.toUpperCase()}'),
                    trailing: product.status == ProductStatus.deleted
                        ? IconButton(
                            icon: const Icon(Icons.restore,
                                color: AppColors.primary),
                            onPressed: () {
                              context
                                  .read<AdminProductListBloc>()
                                  .add(AdminProductRestored(product.id));
                            },
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final bloc =
                                      context.read<AdminProductListBloc>();
                                  await context.pushNamed(
                                    AppRoutes.adminProductEdit,
                                    pathParameters: {
                                      'id': product.id.toString(),
                                    },
                                  );
                                  if (context.mounted) {
                                    bloc.add(AdminProductListRefreshed());
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error),
                                onPressed: () => _confirmDelete(
                                    context, product.id, product.name),
                              ),
                            ],
                          ),
                    onTap: product.status == ProductStatus.deleted
                        ? null
                        : () async {
                            final bloc = context.read<AdminProductListBloc>();
                            await context.pushNamed(
                              AppRoutes.adminProductDetail,
                              pathParameters: {'id': product.id.toString()},
                            );
                            if (context.mounted) {
                              bloc.add(AdminProductListRefreshed());
                            }
                          },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
