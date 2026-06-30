import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_empty_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';

class CategoryLoadingView extends StatelessWidget {
  const CategoryLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const AppLoadingView();
}

class CategoryEmptyView extends StatelessWidget {
  const CategoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) => const AppEmptyView(
        icon: Icons.category_outlined,
        title: AppStrings.adminCategoryEmptyTitle,
        message: AppStrings.adminCategoryEmptyMessage,
      );
}

class CategoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CategoryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => AppErrorView(
        title: AppStrings.adminCategoryLoadErrorTitle,
        message: message,
        onRetry: onRetry,
      );
}
