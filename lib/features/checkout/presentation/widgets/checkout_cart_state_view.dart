import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_state_views.dart';

class CheckoutCartStateView extends StatelessWidget {
  final Widget Function(BuildContext context, CartLoaded state) contentBuilder;

  const CheckoutCartStateView({
    super.key,
    required this.contentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, checkoutState) {
        final isCheckoutBusy = checkoutState is CheckoutLoading ||
            checkoutState is CheckoutVerifying;

        return Stack(
          children: [
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
                  return const _CheckoutLoadingIndicator();
                }
                if (state is CartLoaded) {
                  if (state.items.isEmpty) {
                    return const CheckoutEmptyState();
                  }
                  return contentBuilder(context, state);
                }
                if (state is CartError) {
                  return CheckoutErrorStateView(
                    message: state.message,
                    onRetry: () => context.read<CartCubit>().loadCart(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (isCheckoutBusy)
              const ColoredBox(
                color: Color(0x66FFFFFF),
                child: _CheckoutLoadingIndicator(),
              ),
          ],
        );
      },
    );
  }
}

class _CheckoutLoadingIndicator extends StatelessWidget {
  const _CheckoutLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
