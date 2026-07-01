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
  const AdminOrderListPage({super.key});

  @override
  State<AdminOrderListPage> createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
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
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminOrderCubit>().loadMoreOrders();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<AdminOrderCubit>().applyFilters(search: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AdminOrderCubit, AdminOrderState>(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.paddingMd, AppSizes.paddingMd,
                    AppSizes.paddingMd, AppSizes.paddingSm),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: AppStrings.adminOrderSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: AppSizes.iconMd),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSizes.spacing12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      borderSide:
                          const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              _buildStatusFilters(context, state),
              Expanded(child: _buildBody(context, state, currencyFormat)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context, AdminOrderState state) {
    final selected = state is AdminOrderListLoaded ? state.statusFilter : null;

    return SizedBox(
      height: AppSizes.buttonMinHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildBody(
    BuildContext context,
    AdminOrderState state,
    NumberFormat currencyFormat,
  ) {
    if (state is AdminOrderListLoading) {
      return const Center(
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
            const SizedBox(height: AppSizes.spacing12),
            FilledButton(
              onPressed: () =>
                  context.read<AdminOrderCubit>().refreshList(),
              child: const Text(AppStrings.retry),
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
          padding: const EdgeInsets.all(16),
          itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.orders.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
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
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        checkmarkColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
