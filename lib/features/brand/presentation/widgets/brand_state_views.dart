import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_empty_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';

class BrandLoadingView extends StatelessWidget {
  const BrandLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const AppLoadingView();
}

class BrandEmptyView extends StatelessWidget {
  const BrandEmptyView({super.key});

  @override
  Widget build(BuildContext context) => const AppEmptyView(
        icon: Icons.branding_watermark_outlined,
        title: AppStrings.adminBrandEmptyTitle,
      );
}

class BrandErrorView extends StatelessWidget {
  final String message;

  const BrandErrorView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => AppErrorView(
        title: AppStrings.productFilterBrandLoadError,
        message: message,
      );
}
