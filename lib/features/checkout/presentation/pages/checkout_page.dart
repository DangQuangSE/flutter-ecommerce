import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/core/constants/payment_method_constants.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/payment_method_selector.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_ecommerce/features/payment/domain/entities/vnpay_payment_result.dart';
import 'package:flutter_ecommerce/features/payment/presentation/models/vnpay_payment_extra.dart';

class CheckoutPage extends StatefulWidget {
  final List<int>? cartItemIds;
  const CheckoutPage({super.key, this.cartItemIds});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  CheckoutPaymentOption _selectedPayment = CheckoutPaymentOption.cod;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Alex Mercer');
    _phoneController = TextEditingController(text: '0987654321');
    _addressController = TextEditingController(
      text: '123 Lê Lợi, Quận 1, TP. Hồ Chí Minh, Việt Nam',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _normalizePhone(String raw) => raw.replaceAll(RegExp(r'\s+'), '');

  Future<void> _openVnpayWebView(
    BuildContext context,
    CheckoutAwaitingPayment state,
  ) async {
    final result = await context.pushNamed<VnpayPaymentResult?>(
      AppRoutes.vnpayPayment,
      extra: VnpayPaymentExtra(
        orderId: state.session.orderId,
        paymentUrl: state.session.paymentUrl,
      ),
    );
    if (!context.mounted) return;
    context.read<CheckoutBloc>().add(
          CheckoutPaymentReturned(
            orderId: state.session.orderId,
            result: result,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (previous, current) =>
          (current is CheckoutAwaitingPayment &&
              previous is! CheckoutAwaitingPayment) ||
          current is CheckoutSuccess ||
          current is CheckoutFailure,
      listener: (context, checkoutState) async {
        if (checkoutState is CheckoutAwaitingPayment) {
          await _openVnpayWebView(context, checkoutState);
        } else if (checkoutState is CheckoutSuccess) {
          await context.read<CartCubit>().loadCart();
          if (!context.mounted) return;
          context.goNamed(AppRoutes.checkoutSuccess);
        } else if (checkoutState is CheckoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                checkoutState.message,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
              height: 1,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.cart);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          title: Text(
            'THANH TOÁN',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, checkoutState) {
            final isCheckoutBusy = checkoutState is CheckoutLoading ||
                checkoutState is CheckoutVerifying;

            return Stack(
              children: [
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    if (state is CartLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      );
                    } else if (state is CartLoaded) {
                      if (state.items.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildCheckoutContent(context, state);
                    } else if (state is CartError) {
                      return _buildErrorState(state.message);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (isCheckoutBusy)
                  const ColoredBox(
                    color: Color(0x66FFFFFF),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Transform(
              transform: Matrix4.skewX(-0.12),
              child: Text(
                'ĐƠN HÀNG RỖNG',
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy sản phẩm nào để thanh toán. Hãy quay về giỏ hàng hoặc tiếp tục mua sắm nhé!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRoutes.productList),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'QUAY LẠI MUA SẮM',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutContent(BuildContext context, CartLoaded state) {
    final checkoutItems = widget.cartItemIds != null
        ? state.items
            .where((e) => widget.cartItemIds!.contains(e.itemId))
            .toList()
        : state.items;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Shipping Section
                  _buildSectionHeader(
                      'THÔNG TIN GIAO HÀNG', Icons.local_shipping_outlined),
                  const SizedBox(height: 12),
                  _buildShippingForm(),
                  const SizedBox(height: 28),

                  // Payment Section
                  _buildSectionHeader(
                      'PHƯƠNG THỨC THANH TOÁN', Icons.payments_outlined),
                  const SizedBox(height: 12),
                  PaymentMethodSelector(
                    selected: _selectedPayment,
                    onChanged: (option) {
                      setState(() => _selectedPayment = option);
                    },
                  ),
                  const SizedBox(height: 28),

                  // Summary Section
                  _buildOrderSummary(checkoutItems),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildStickyFooter(context, checkoutItems),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'HỌ VÀ TÊN',
            controller: _nameController,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập họ và tên'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'SỐ ĐIỆN THOẠI',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập số điện thoại'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'ĐỊA CHỈ GIAO HÀNG',
            controller: _addressController,
            maxLines: 2,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập địa chỉ giao hàng'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF3F3F8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(List<CartItemEntity> checkoutItems) {
    final checkoutTotalItems =
        checkoutItems.fold(0, (sum, e) => sum + e.quantity);
    final checkoutTotalPrice = checkoutItems.fold(
        0.0, (sum, e) => sum + (e.price + e.printingPrice) * e.quantity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính ($checkoutTotalItems sản phẩm)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatPrice(checkoutTotalPrice),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao hàng hỏa tốc',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Miễn phí',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF009933),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TỔNG CỘNG',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              Transform(
                transform: Matrix4.skewX(-0.12),
                child: Text(
                  _formatPrice(checkoutTotalPrice),
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(
      BuildContext context, List<CartItemEntity> checkoutItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final cartItemIds =
                    checkoutItems.map((item) => item.itemId).toList();
                context.read<CheckoutBloc>().add(
                      CheckoutSubmitted(
                        OrderRequestEntity(
                          shippingAddress: _addressController.text.trim(),
                          phoneNumber: _normalizePhone(_phoneController.text),
                          customerName: _nameController.text.trim(),
                          paymentMethod: _selectedPayment.apiValue,
                          cartItemIds: cartItemIds,
                        ),
                      ),
                    );
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text(
                      'Vui lòng điền đầy đủ thông tin giao hàng!',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent, // Safety Orange
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONFIRM ORDER',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.bolt_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thông tin thanh toán.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<CartCubit>().loadCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
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
