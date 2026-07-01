import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_state.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_actions.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_layer_handlers.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_page.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/canvas_workspace.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/design_config_panel.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/pricing_footer.dart';

extension CustomizerViewHelpers on CustomizerPageState {
  Widget buildLoading() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: buildAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoadingView(),
            AppSizes.spacingMd,
            Text(
              AppStrings.customizerLoading,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildError(String message) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: buildAppBar(context),
      body: Center(
        child: Padding(
          padding: AppSizes.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              AppSizes.spacingMd,
              Text(
                AppStrings.customizerLoadError,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSizes.spacingSm,
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSizes.paddingLg),
              ElevatedButton(
                onPressed: () =>
                    context.read<CustomizerCubit>().loadPrintingConfigs(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoaded({bool isSaving = false}) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: buildAppBar(context),
          body: SafeArea(
            child: Column(
              children: [
                buildCanvasSection(),
                Expanded(flex: 6, child: buildConfigPanel()),
                PricingFooter(
                  totalPrice: totalPrice,
                  totalPrintingPrice: totalPrintingPrice,
                  onReset: handleReset,
                  onConfirm: handleConfirm,
                ),
              ],
            ),
          ),
        ),
        if (isSaving) buildSavingOverlay(),
      ],
    );
  }

  Widget buildSavingOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.black.withValues(alpha: 0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoadingView(color: AppColors.accent),
              AppSizes.spacingMd,
              Text(
                AppStrings.customizerSaving,
                style: GoogleFonts.inter(
                  color: AppColors.white,
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildConfigPanel() {
    return DesignConfigPanel(
      printMethod: printMethod,
      onPrintMethodChanged: onPrintMethodChanged,
      activeLayer: activeLayer,
      textController: textController,
      fontsList: fontsList,
      presetColors: effectiveColors,
      getFontFamily: getFontFamily,
      onTextChanged: (value) =>
          onActiveLayerPropChanged((layer) => layer.copyWith(text: value)),
      onFontChanged: (value) =>
          onActiveLayerPropChanged((layer) => layer.copyWith(font: value)),
      onColorSelected: (color) =>
          onActiveLayerPropChanged((layer) => layer.copyWith(color: color)),
      onCustomColorTap: showColorPicker,
      onFontSizeChanged: (value) =>
          onActiveLayerPropChanged((layer) => layer.copyWith(fontSize: value)),
      onAddLayer: addNewTextLayer,
      onUploadLogo: uploadLogo,
      layers: layers,
      activeLayerId: activeLayer?.id,
      onLayerActivated: onPanelLayerActivated,
      onLayerDeleted: onPanelLayerDeleted,
      materials: switch (context.read<CustomizerCubit>().state) {
        CustomizerLoaded(:final printingConfigs) => printingConfigs.materials,
        _ => null,
      },
    );
  }

  Widget buildCanvasSection() {
    return Expanded(
      flex: 5,
      child: CanvasWorkspace(
        canvasKey: canvasKey,
        layers: layers,
        activeLayerId: activeLayer?.id,
        isFrontView: isFrontView,
        zoomScale: zoomScale,
        rotationAngle: rotationAngle,
        onFrontViewChanged: onFrontViewChanged,
        onZoomChanged: onZoomChanged,
        onLayerActivated: onLayerActivatedFromCanvas,
        onLayerDragged: onLayerDragged,
        onLayerDeleted: onLayerDeletedFromCanvas,
        getFontFamily: getFontFamily,
      ),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderGray.withValues(alpha: 0.3),
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
        icon: Icon(
          Icons.close_rounded,
          color: theme.colorScheme.onSurface,
          size: AppSizes.iconLg,
        ),
      ),
      title: Column(
        children: [
          Transform(
            transform: Matrix4.skewX(-0.12),
            child: Text(
              AppStrings.customizerTitle,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 2),
          Text(
            widget.productName,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
