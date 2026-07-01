import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_empty_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';

class ColorLoadingView extends StatelessWidget {
  const ColorLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const AppLoadingView();
}

class ColorEmptyView extends StatelessWidget {
  final String message;

  const ColorEmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) => AppEmptyView(
        icon: Icons.palette_outlined,
        title: message,
      );
}

class ColorErrorView extends StatelessWidget {
  final String message;

  const ColorErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) => AppErrorView(
        title: AppStrings.genericLoadError,
        message: message,
      );
}
