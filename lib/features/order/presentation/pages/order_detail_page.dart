import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_entity.dart';
import 'package:flutter_ecommerce/features/order/domain/entities/order_item_entity.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_state.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_detail_app_bar.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_detail_body.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/detail/order_detail_error_view.dart';
import 'package:flutter_ecommerce/features/review/presentation/pages/write_review_page.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          current is CancelOrderSuccess || current is CancelOrderError,
      listener: (context, state) {
        if (state is CancelOrderSuccess) {
          AppSnackBar.show(context, message: 'Hủy đơn hàng thành công', type: AppSnackBarType.success);
          final id = int.tryParse(orderId) ?? 0;
          context.read<OrderBloc>().add(OrderDetailRequested(id));
        } else if (state is CancelOrderError) {
          AppSnackBar.show(context, message: state.message, type: AppSnackBarType.error);
        }
      },
      child: Scaffold(
        appBar: const OrderDetailAppBar(),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
          return switch (state) {
            OrderDetailLoading() || OrderInitial() => const AppLoadingView(),
            OrderDetailError(:final message) => OrderDetailErrorView(
                message: message,
                onRetry: () {
                  final id = int.tryParse(orderId) ?? 0;
                  context.read<OrderBloc>().add(OrderDetailRequested(id));
                },
              ),
            OrderDetailLoaded(:final order) => OrderDetailBody(
                order: order,
                onReviewRequested: (context, item) =>
                    _openWriteReview(context, order, item),
                onCancelRequested: () => _showCancelDialog(context, order),
              ),
            _ => const AppLoadingView(),
          };
        },
      ),
    ));
  }

  Future<void> _openWriteReview(
    BuildContext context,
    OrderEntity order,
    OrderItemEntity item,
  ) async {
    final reviewed = await context.pushNamed<bool>(
      AppRoutes.writeReview,
      pathParameters: {'orderId': order.id.toString()},
      extra:
          WriteReviewArgs(orderItemId: item.id, productName: item.productName),
    );
    if (reviewed == true && context.mounted) {
      context.read<OrderBloc>().add(OrderDetailRequested(order.id));
    }
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hủy Đơn Hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (order.paymentMethod == 'VNPAY')
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Admin sẽ liên hệ hoàn tiền qua số điện thoại mà khách hàng đã đặt hàng.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do hủy đơn',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  AppSnackBar.show(dialogContext, message: 'Vui lòng nhập lý do hủy đơn', type: AppSnackBarType.error);
                  return;
                }
                Navigator.pop(dialogContext);
                context.read<OrderBloc>().add(CancelOrderRequested(
                      orderId: order.id,
                      reason: reasonController.text.trim(),
                    ));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xác nhận Hủy', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
