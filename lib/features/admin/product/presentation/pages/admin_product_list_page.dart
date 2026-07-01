import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_empty_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/bloc/admin_product_list_bloc.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  static const double _thumbnailSize = 48;
  static const double _loadMoreThreshold = 200;

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
        _scrollController.position.maxScrollExtent - _loadMoreThreshold) {
      context.read<AdminProductListBloc>().add(AdminProductListLoadedMore());
    }
  }

  Future<void> _confirmDelete(BuildContext context, int id, String name) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.adminProductDeleteTitle,
      message: AppStrings.adminProductDeleteMessage(name),
      confirmLabel: AppStrings.delete,
    );
    if (confirmed && context.mounted) {
      context.read<AdminProductListBloc>().add(AdminProductDeleted(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminProductListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: show search bar / filter sheet.
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
            AppSnackBar.show(
              context,
              message: state.message,
              type: AppSnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is AdminProductListLoading) {
            return const AppLoadingView();
          }
          if (state is AdminProductListFailure) {
            return AppErrorView(
              title: AppStrings.genericLoadError,
              message: state.message,
              onRetry: () => context
                  .read<AdminProductListBloc>()
                  .add(AdminProductListLoaded()),
            );
          }
          if (state is AdminProductListSuccess) {
            if (state.totalElements == 0 && state.products.isEmpty) {
              return const AppEmptyView(
                icon: Icons.inventory_2_outlined,
                title: AppStrings.adminProductListEmpty,
              );
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
                      padding: EdgeInsets.all(AppSizes.paddingMd),
                      child: AppLoadingView(),
                    );
                  }
                  final product = state.products[index];
                  return ListTile(
                    leading: _ProductThumbnail(url: product.thumbnailUrl),
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.brandName} • '
                      '${product.status.name.toUpperCase()}',
                    ),
                    trailing: product.status == ProductStatus.deleted
                        ? IconButton(
                            icon: const Icon(
                              Icons.restore,
                              color: AppColors.primary,
                            ),
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
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _confirmDelete(
                                  context,
                                  product.id,
                                  product.name,
                                ),
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

class _ProductThumbnail extends StatelessWidget {
  final String? url;

  const _ProductThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textHint,
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: _AdminProductListPageState._thumbnailSize,
      height: _AdminProductListPageState._thumbnailSize,
      fit: BoxFit.cover,
      placeholder: (_, __) => const SizedBox(
        width: _AdminProductListPageState._thumbnailSize,
        height: _AdminProductListPageState._thumbnailSize,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textHint,
      ),
    );
  }
}
