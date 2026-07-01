import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_state.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/models/coupon_form_extra.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/management/coupon_detail_sheet.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/management/coupon_management_app_bar.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/management/coupon_management_list.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/management/coupon_search_bar.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/widgets/management/coupon_state_views.dart';

class CouponManagementPage extends StatefulWidget {
  const CouponManagementPage({super.key});

  @override
  State<CouponManagementPage> createState() => _CouponManagementPageState();
}

class _CouponManagementPageState extends State<CouponManagementPage> {
  final _searchController = TextEditingController();

  /// Client-side filter: the backend list endpoint has no search parameter.
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CouponCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CouponCubit get _cubit => context.read<CouponCubit>();

  void _openForm({CouponEntity? coupon}) {
    context.pushNamed(
      AppRoutes.adminCouponForm,
      extra: CouponFormExtra(
        cubit: _cubit,
        coupon: coupon,
      ),
    );
  }

  void _handleSearchChanged(String value) {
    setState(() => _query = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _confirmDelete(CouponEntity coupon) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.adminCouponDeleteTitle,
      message: AppStrings.adminCouponDeleteMessage(coupon.code),
      confirmLabel: AppStrings.delete,
    );

    if (!confirmed || coupon.id == null) return;
    final error = await _cubit.delete(coupon.id!);
    if (!mounted) return;
    _showSnack(error ?? AppStrings.adminCouponDeleted, isError: error != null);
  }

  Future<void> _toggle(CouponEntity coupon) async {
    final error = await _cubit.toggleStatus(coupon, isActive: !coupon.isActive);
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

  void _showDetail(CouponEntity coupon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusRound)),
      ),
      builder: (_) => CouponDetailSheet(coupon: coupon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const CouponManagementAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.adminCatalogAdd),
      ),
      body: Column(
        children: [
          CouponSearchBar(
            controller: _searchController,
            query: _query,
            onChanged: _handleSearchChanged,
            onClear: _clearSearch,
          ),
          Expanded(
            child: BlocBuilder<CouponCubit, CouponState>(
              builder: (context, state) {
                return switch (state) {
                  CouponLoading() => const AppLoadingView(),
                  CouponError(:final message) => CouponErrorView(
                      message: message,
                      onRetry: _cubit.load,
                    ),
                  CouponLoaded() => _CouponLoadedView(
                      state: state,
                      query: _query,
                      onCreate: () => _openForm(),
                      onRefresh: _cubit.refresh,
                      onOpenDetail: _showDetail,
                      onEdit: (coupon) => _openForm(coupon: coupon),
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

class _CouponLoadedView extends StatelessWidget {
  final CouponLoaded state;
  final String query;
  final VoidCallback onCreate;
  final Future<void> Function() onRefresh;
  final ValueChanged<CouponEntity> onOpenDetail;
  final ValueChanged<CouponEntity> onEdit;
  final ValueChanged<CouponEntity> onDelete;
  final ValueChanged<CouponEntity> onToggle;

  const _CouponLoadedView({
    required this.state,
    required this.query,
    required this.onCreate,
    required this.onRefresh,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (state.coupons.isEmpty) {
      return CouponEmptyView(onCreate: onCreate);
    }

    final filtered = query.isEmpty
        ? state.coupons
        : state.coupons
            .where((coupon) =>
                coupon.code.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return CouponManagementList(
      state: state,
      filtered: filtered,
      query: query,
      onRefresh: onRefresh,
      onOpenDetail: onOpenDetail,
      onEdit: onEdit,
      onDelete: onDelete,
      onToggle: onToggle,
    );
  }
}
