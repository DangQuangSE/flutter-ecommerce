import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_state.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/constants/payment_method_constants.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_state.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/checkout/domain/entities/order_request_entity.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_app_bar.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_body.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/checkout_cart_state_view.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/widgets/coupon_selection_sheet.dart';
import 'package:flutter_ecommerce/features/coupon/domain/entities/coupon_entity.dart';
import 'package:flutter_ecommerce/features/coupon/domain/enums/discount_type.dart';
import 'package:flutter_ecommerce/features/payment/domain/entities/vnpay_payment_result.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
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
  CouponEntity? _selectedCoupon;
  AddressEntity? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _addressController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double _calculateDiscount(double subtotal) {
    if (_selectedCoupon == null) return 0;
    if (_selectedCoupon!.minOrderAmount != null &&
        subtotal < _selectedCoupon!.minOrderAmount!) {
      return 0;
    }

    double discount = 0;
    if (_selectedCoupon!.discountType == DiscountType.percentage) {
      discount = subtotal * (_selectedCoupon!.discountValue / 100);
      if (_selectedCoupon!.maxDiscountAmount != null &&
          discount > _selectedCoupon!.maxDiscountAmount!) {
        discount = _selectedCoupon!.maxDiscountAmount!;
      }
    } else if (_selectedCoupon!.discountType == DiscountType.fixedAmount) {
      discount = _selectedCoupon!.discountValue;
    }

    return discount > subtotal ? subtotal : discount;
  }

  void _onAddressSelected(AddressEntity address) {
    setState(() {
      _selectedAddress = address;
      _nameController.text = address.fullName;
      _phoneController.text = address.phoneNumber;
      _addressController.text = address.formattedAddress;
    });
  }

  void _autoSelectDefaultAddress(List<AddressEntity> addresses) {
    if (_selectedAddress != null || addresses.isEmpty) return;
    AddressEntity chosen = addresses.first;
    for (final address in addresses) {
      if (address.isDefault) {
        chosen = address;
        break;
      }
    }
    _onAddressSelected(chosen);
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

  void _submitOrder(BuildContext context, List<CartItemEntity> checkoutItems) {
    if (_selectedAddress == null) {
      _showCheckoutError(context, AppStrings.checkoutAddressRequired);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showCheckoutError(context, AppStrings.checkoutShippingInfoRequired);
      return;
    }

    final cartItemIds = checkoutItems.map((item) => item.itemId).toList();
    context.read<CheckoutBloc>().add(
          CheckoutSubmitted(
            OrderRequestEntity(
              shippingAddress: _addressController.text.trim(),
              phoneNumber: _normalizePhone(_phoneController.text),
              customerName: _nameController.text.trim(),
              paymentMethod: _selectedPayment.apiValue,
              cartItemIds: cartItemIds,
              couponCode: _selectedCoupon?.code,
            ),
          ),
        );
  }

  void _showCheckoutError(BuildContext context, String message) {
    AppSnackBar.show(
      context,
      message: message,
      type: AppSnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddressCubit, AddressState>(
          listenWhen: (previous, current) => current is AddressLoaded,
          listener: (context, addressState) {
            if (addressState is AddressLoaded) {
              _autoSelectDefaultAddress(addressState.addresses);
            }
          },
        ),
        BlocListener<CheckoutBloc, CheckoutState>(
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
              await context.read<CustomizerCubit>().clearAllCustomizations();
              if (!context.mounted) return;
              context.goNamed(AppRoutes.checkoutSuccess);
            } else if (checkoutState is CheckoutFailure) {
              _showCheckoutError(context, checkoutState.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CheckoutAppBar(),
        body: CheckoutCartStateView(contentBuilder: _buildCheckoutContent),
      ),
    );
  }

  Widget _buildCheckoutContent(BuildContext context, CartLoaded state) {
    final checkoutItems = widget.cartItemIds != null
        ? state.items
            .where((item) => widget.cartItemIds!.contains(item.itemId))
            .toList()
        : state.items;

    final specCubit = context.read<CustomDesignSpecCubit>();
    for (final item in checkoutItems) {
      final designId = item.customDesignId;
      if (designId != null) specCubit.loadSpec(designId);
    }

    return BlocBuilder<CustomDesignSpecCubit, CustomDesignSpecState>(
      builder: (context, specState) {
        final specSnapshot =
            specState is CustomDesignSpecSnapshot ? specState : null;
        return CheckoutBody(
          formKey: _formKey,
          checkoutItems: checkoutItems,
          specSnapshot: specSnapshot,
          selectedAddress: _selectedAddress,
          selectedCoupon: _selectedCoupon,
          selectedPayment: _selectedPayment,
          nameController: _nameController,
          phoneController: _phoneController,
          addressController: _addressController,
          onAddressSelected: _onAddressSelected,
          onPaymentChanged: (option) {
            setState(() => _selectedPayment = option);
          },
          calculateDiscount: _calculateDiscount,
          formatPrice: _formatPrice,
          onOpenCoupon: _openCouponDialog,
          onConfirm: () => _submitOrder(context, checkoutItems),
        );
      },
    );
  }

  void _openCouponDialog(
    BuildContext context,
    double subtotal, {
    required List<CouponEntity> coupons,
    required String? errorMessage,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingXl,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusRound)),
        ),
        child: CouponSelectionSheet(
          subtotal: subtotal,
          selectedCoupon: _selectedCoupon,
          coupons: coupons,
          errorMessage: errorMessage,
          onCouponSelected: (coupon) {
            setState(() {
              _selectedCoupon = coupon;
            });
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatStr = price.toInt().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < formatStr.length; index++) {
      buffer.write(formatStr[index]);
      if ((formatStr.length - 1 - index) % 3 == 0 &&
          index != formatStr.length - 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}
