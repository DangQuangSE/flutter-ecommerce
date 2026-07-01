import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
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
    return Scaffold(
      
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
              ),
            _ => const AppLoadingView(),
          };
        },
      ),
    );
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
}
