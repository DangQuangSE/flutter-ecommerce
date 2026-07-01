import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/admin/presentation/widgets/admin_order_card.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_state.dart';

class AdminOrderListPage extends StatefulWidget {
  final bool showAppBar;

  const AdminOrderListPage({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<AdminOrderListPage> createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
  static const double _loadMoreThreshold = 200;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _loadMoreThreshold) {
      context.read<AdminOrderCubit>().loadMoreOrders();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final state = context.read<AdminOrderCubit>().state;
      context.read<AdminOrderCubit>().applyFilters(
            search: value,
            status: state is AdminOrderListLoaded ? state.statusFilter : null,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final content = BlocConsumer<AdminOrderCubit, AdminOrderState>(
      listener: (context, state) {
        if (state is AdminOrderListLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            if (!widget.showAppBar) _buildInlineHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.paddingMd,
                  AppSizes.paddingMd, AppSizes.paddingMd, AppSizes.paddingSm),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: AppStrings.adminOrderSearchHint,
                  prefixIcon:
                      Icon(Icons.search_rounded, size: AppSizes.iconMd),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: AppSizes.spacing12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            _buildStatusFilters(context, state),
            _buildDateRangeFilter(context, state),
            Expanded(child: _buildBody(context, state, currencyFormat)),
          ],
        );
      },
    );

    return Scaffold(
      
      appBar: widget.showAppBar
          ? AppBar(
              elevation: 0,
              centerTitle: true,
              title: Text(
                AppStrings.adminOrderManagementTitle,
                style: GoogleFonts.lexend(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.fontXxl,
                ),
              ),
              iconTheme: IconThemeData(color: AppColors.textPrimary),
            )
          : null,
      body: widget.showAppBar ? content : SafeArea(child: content),
    );
  }

  Widget _buildInlineHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMd,
        AppSizes.paddingLg,
        AppSizes.paddingMd,
        AppSizes.paddingXs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppStrings.adminOrderManagementTitle,
          style: GoogleFonts.lexend(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: AppSizes.fontTitle,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context, AdminOrderState state) {
    final selected = state is AdminOrderListLoaded ? state.statusFilter : null;

    return SizedBox(
      height: AppSizes.buttonMinHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
        children: [
          _StatusChip(
            label: AppStrings.filterAll,
            isSelected: selected == null,
            onTap: () => context.read<AdminOrderCubit>().applyFilters(
                  search: _searchController.text,
                  status: null,
                ),
          ),
          ...OrderStatusLabel.allStatuses.map(
            (status) => _StatusChip(
              label: OrderStatusLabel.vi(status),
              isSelected: selected == status,
              onTap: () => context.read<AdminOrderCubit>().applyFilters(
                    search: _searchController.text,
                    status: status,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context, AdminOrderState state) {
    final startDate =
        state is AdminOrderListLoaded ? state.startDateFilter : null;
    final endDate = state is AdminOrderListLoaded ? state.endDateFilter : null;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final label = startDate == null && endDate == null
        ? AppStrings.adminOrderDateRangeAll
        : '${startDate == null ? '' : dateFormat.format(startDate)}'
            ' - ${endDate == null ? '' : dateFormat.format(endDate)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMd,
        AppSizes.paddingSm,
        AppSizes.paddingMd,
        AppSizes.paddingXs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: AppStrings.adminOrderDateRangeAction,
              child: OutlinedButton.icon(
                onPressed: () => _selectDateRange(context, startDate, endDate),
                icon:
                    Icon(Icons.date_range_rounded, size: AppSizes.iconSm),
                label: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (startDate != null || endDate != null) ...[
            SizedBox(width: AppSizes.paddingSm),
            IconButton(
              tooltip: AppStrings.adminOrderDateRangeClear,
              onPressed: () => context.read<AdminOrderCubit>().applyFilters(
                    search: _searchController.text,
                    status: state is AdminOrderListLoaded
                        ? state.statusFilter
                        : null,
                    clearStartDate: true,
                    clearEndDate: true,
                  ),
              icon: Icon(Icons.close_rounded),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDateRange(
    BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: startDate == null || endDate == null
          ? null
          : DateTimeRange(start: startDate, end: endDate),
    );
    if (range == null || !context.mounted) return;

    final state = context.read<AdminOrderCubit>().state;
    context.read<AdminOrderCubit>().applyFilters(
          search: _searchController.text,
          status: state is AdminOrderListLoaded ? state.statusFilter : null,
          startDate: range.start,
          endDate: range.end,
        );
  }

  Widget _buildBody(
    BuildContext context,
    AdminOrderState state,
    NumberFormat currencyFormat,
  ) {
    if (state is AdminOrderListLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (state is AdminOrderListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, textAlign: TextAlign.center),
            SizedBox(height: AppSizes.spacing12),
            FilledButton(
              onPressed: () => context.read<AdminOrderCubit>().refreshList(),
              child: Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }

    if (state is AdminOrderListLoaded) {
      if (state.orders.isEmpty) {
        return Center(
          child: Text(
            AppStrings.adminOrderEmpty,
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<AdminOrderCubit>().refreshList(),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.orders.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.paddingMd),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              );
            }

            final order = state.orders[index];
            return AdminOrderCard(
              key: ValueKey(order.id),
              order: order,
              currencyFormat: currencyFormat,
              onTap: () async {
                await context.pushNamed(
                  AppRoutes.adminOrderDetail,
                  pathParameters: {'orderId': order.id.toString()},
                );
                if (context.mounted) {
                  context.read<AdminOrderCubit>().refreshList();
                }
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.paddingSm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        checkmarkColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(
          fontSize: AppSizes.fontMd,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}