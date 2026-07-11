import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/payment/domain/entities/vnpay_payment_result.dart';
import 'package:flutter_ecommerce/features/payment/presentation/models/vnpay_payment_extra.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VnpayPaymentPage extends StatefulWidget {
  final VnpayPaymentExtra extra;

  const VnpayPaymentPage({super.key, required this.extra});

  @override
  State<VnpayPaymentPage> createState() => _VnpayPaymentPageState();
}

class _VnpayPaymentPageState extends State<VnpayPaymentPage> {
  bool _isLoading = true;

  Future<void> _onCancelPressed() async {
    final shouldCancel = await AppConfirmDialog.show(
      context,
      title: AppStrings.paymentCancelTitle,
      message: AppStrings.paymentCancelMessage,
      cancelLabel: AppStrings.paymentContinue,
      confirmLabel: AppStrings.paymentCancel,
    );
    if (shouldCancel == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.paymentVnpayTitle,
          style: GoogleFonts.lexend(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _onCancelPressed,
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.extra.paymentUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
            ),
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri != null &&
                  uri.scheme == 'sportpro' &&
                  uri.host == 'payment-result') {
                Navigator.of(context).pop(VnpayPaymentResult.fromUri(uri));
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
          ),
          if (_isLoading) const AppLoadingView(),
        ],
      ),
    );
  }
}
