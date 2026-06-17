import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/utils/customer_order_filter.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/core/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/app/router/navigation_history.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_state.dart';
import 'package:intl/intl.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      context.read<OrderBloc>().add(const OrderListLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    NavigationHistory.pushTab(AppRoutes.orderList);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          if (context.canPop()) {
            context.pop();
          } else {
            final prevTab = NavigationHistory.popTab();
            if (prevTab != null) {
              context.goNamed(prevTab);
            }
          }
        },
        child: Stack(
          children: [
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<OrderBloc>().add(const OrderListRequested());
                    await context.read<OrderBloc>().stream.firstWhere(
                          (s) => s is OrderListLoaded || s is OrderListError,
                        );
                  },
                  child: _buildScrollView(statusBarHeight, state),
                );
              },
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassAppBar(
                showBackButton: false,
                customTitle: 'Sport Pro',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GlassBottomBar(currentTab: 'orders'),
    );
  }

  Widget _buildScrollView(double statusBarHeight, OrderState state) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 92, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'QUẢN LÝ GIAO DỊCH',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Đơn Hàng Của Tôi',
              style: GoogleFonts.lexend(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.6,
              ),
            ),
          ),
          _buildFilterPillsRow(state),
          const SizedBox(height: 24),
          _buildBodyContent(state),
        ],
      ),
    );
  }

  Widget _buildFilterPillsRow(OrderState state) {
    final selectedFilter = state is OrderListLoaded
        ? state.selectedFilter
        : CustomerOrderFilter.defaultPill;

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: CustomerOrderFilter.pills.length,
        itemBuilder: (context, index) {
          final filter = CustomerOrderFilter.pills[index];
          final isSelected = filter == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.read<OrderBloc>().add(OrderFilterChanged(filter));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.textPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.textPrimary
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(OrderState state) {
    return switch (state) {
      OrderListLoading() => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      OrderListError(:final message) => _buildErrorState(message),
      OrderListLoaded(:final orders, :final isLoadingMore, :final message) =>
        Column(
          children: [
            if (message != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (orders.isEmpty)
              _buildEmptyState()
            else
              _buildOrdersList(orders),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      _ => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
    };
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<OrderBloc>().add(const OrderListRequested());
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có đơn hàng nào',
            style: GoogleFonts.lexend(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Các giao dịch thuộc danh mục này sẽ xuất hiện tại đây.',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderEntity> orders) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
        ),
        itemBuilder: (context, index) {
          return _buildOrderListItem(context, orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderListItem(BuildContext context, OrderEntity order) {
    final item = order.primaryItem;
    final statusLabel = OrderStatusLabel.vi(order.status);
    final (_, statusColor) = OrderStatusLabel.badgeColors(order.status);
    final dateStr = DateFormat('dd/MM/yyyy').format(order.createdAt);

    return GestureDetector(
      onTap: () => context.goNamed(
        AppRoutes.orderDetail,
        pathParameters: {'orderId': order.id.toString()},
      ),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Container(
              width: 68,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: item?.imageUrl != null && item!.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.displayCode,
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BreathingPulseDot(color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item?.productName ?? 'Không có sản phẩm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item?.size ?? '—'}  ·  Số lượng: ${item?.quantity ?? 0}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatPrice(order.totalAmount),
                      style: GoogleFonts.spaceMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final formatStr = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < formatStr.length; i++) {
      buffer.write(formatStr[i]);
      if ((formatStr.length - 1 - i) % 3 == 0 && i != formatStr.length - 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}

class BreathingPulseDot extends StatefulWidget {
  final Color color;
  const BreathingPulseDot({super.key, required this.color});

  @override
  State<BreathingPulseDot> createState() => _BreathingPulseDotState();
}

class _BreathingPulseDotState extends State<BreathingPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 10 + (8 * _controller.value),
              height: 10 + (8 * _controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color
                    .withValues(alpha: 0.5 * (1.0 - _controller.value)),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
