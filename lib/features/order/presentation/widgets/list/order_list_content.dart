import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_state.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/list/order_filter_pills_row.dart';
import 'package:flutter_ecommerce/features/order/presentation/widgets/list/order_list_state_views.dart';

class OrderListContent extends StatelessWidget {
  final double statusBarHeight;
  final OrderState state;
  final ScrollController scrollController;

  const OrderListContent({
    super.key,
    required this.statusBarHeight,
    required this.state,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 92, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.orderListSectionLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.orderListTitle,
            style: GoogleFonts.lexend(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 16),
          OrderFilterPillsRow(state: state),
          const SizedBox(height: 24),
          OrderListStateView(state: state),
        ],
      ),
    );
  }
}
