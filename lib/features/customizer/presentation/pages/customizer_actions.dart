import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/constants/printing_constants.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_state.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_page.dart';

extension CustomizerActions on CustomizerPageState {
  void addNewTextLayer() {
    updateState(() {
      final offset = (layers.length % 4) * 0.1 - 0.15;
      final newLayer = DesignLayer(
        id: 'layer-${DateTime.now().millisecondsSinceEpoch}',
        type: LayerType.text,
        text: AppStrings.customizerDefaultTextLayer,
        color: AppColors.accentRed,
        fontSize: AppSizes.fontXxl,
        x: offset,
        y: offset,
      );
      layers.add(newLayer);
      activeLayer = newLayer;
      textController.text = newLayer.text;
    });
  }

  Future<void> uploadLogo() async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      updateState(() {
        final newLayer = DesignLayer(
          id: 'layer-${DateTime.now().millisecondsSinceEpoch}',
          type: LayerType.logo,
          logoPath: image.path,
          y: -0.3,
        );
        layers.add(newLayer);
        activeLayer = newLayer;
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppStrings.customizerUploadImageError,
        type: AppSnackBarType.error,
      );
    }
  }

  void handleReset() {
    updateState(() {
      layers.clear();
      activeLayer = null;
      textController.clear();
      printMethod = AppStrings.customizerDefaultPrintMethod;
      zoomScale = 1.0;
      rotationAngle = 0.0;
      isFrontView = true;
      addDefaultLayer();
    });
  }

  void addDefaultLayer() {
    final defaultLayer = DesignLayer(
      id: 'layer-default',
      type: LayerType.text,
      text: AppStrings.customizerDefaultLayerText,
      color: AppColors.accentBlue,
      fontSize: AppSizes.fontHeading,
      y: -0.1,
    );
    layers.add(defaultLayer);
    activeLayer = defaultLayer;
    textController.text = defaultLayer.text;
  }

  Future<Uint8List?> captureCanvas() async {
    try {
      final boundary = canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void showColorPicker() {
    if (activeLayer == null || activeLayer!.type != LayerType.text) return;
    var pickerColor = activeLayer!.color;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppStrings.customizerColorPickerTitle,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.fontMd,
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            onPressed: () => dialogContext.pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              AppStrings.productFilterApply,
              style: GoogleFonts.inter(color: AppColors.white),
            ),
            onPressed: () {
              updateState(() {
                activeLayer = activeLayer!.copyWith(color: pickerColor);
                final index =
                    layers.indexWhere((layer) => layer.id == activeLayer!.id);
                if (index != -1) layers[index] = activeLayer!;
              });
              dialogContext.pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> handleConfirm() async {
    final cubit = context.read<CustomizerCubit>();
    final previousActive = activeLayer;
    updateState(() => activeLayer = null);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await captureCanvas();
    updateState(() => activeLayer = previousActive);
    if (bytes == null) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppStrings.customizerCaptureError,
        type: AppSnackBarType.error,
      );
      return;
    }

    final primary = extractPrimaryTextLayer();
    final hasLogo = layers.any((layer) => layer.type == LayerType.logo);
    final layersJson =
        jsonEncode(layers.map((layer) => layer.toJson()).toList());
    final materialId = selectedMaterial?.id ??
        (printMethod == AppStrings.customizerDefaultPrintMethod
            ? PrintingConstants.heatTransferId
            : PrintingConstants.reflectiveDecalId);
    final textLayersCount =
        layers.where((layer) => layer.type == LayerType.text).length;
    final imagesCount =
        layers.where((layer) => layer.type == LayerType.logo).length;

    await cubit.saveCustomization(
      productId: widget.productId,
      materialId: materialId,
      numTextLines: textLayersCount,
      numImages: imagesCount,
      metadata: layersJson,
      imageBytes: bytes,
      activeText: primary.text,
      activeColor: primary.color,
      activeFontSize: primary.fontSize,
      hasLogo: hasLogo,
      printMethod: printMethod,
      layersJson: layersJson,
    );

    if (!mounted) return;

    final state = context.read<CustomizerCubit>().state;
    if (state is CustomizerLoaded) {
      AppSnackBar.show(
        context,
        message: AppStrings.customizerSaveSuccess,
        type: AppSnackBarType.success,
        icon: Icon(
          Icons.check_circle_rounded,
          color: AppColors.white,
          size: AppSizes.iconMd,
        ),
      );
      if (widget.variantId != null) {
        final savedDesignId = findSavedDesignId();
        if (savedDesignId != null) {
          await widget.onConfirm?.call(savedDesignId);
        }
      }
      if (!mounted) return;
      context.goNamed(AppRoutes.cart);
    } else {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppStrings.customizerSyncError,
        type: AppSnackBarType.error,
      );
    }
  }

  int? findSavedDesignId() {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final savedCustomizations)) {
      return savedCustomizations[widget.productId]?.customDesignId;
    }
    return null;
  }

  ({String text, int color, double fontSize}) extractPrimaryTextLayer() {
    final textLayers = layers.where((layer) => layer.type == LayerType.text);
    if (textLayers.isNotEmpty) {
      final primary = textLayers.first;
      return (
        text: primary.text,
        color: primary.color.toARGB32(),
        fontSize: primary.fontSize,
      );
    }
    return (text: '', color: 0xFF1A1C1F, fontSize: AppSizes.fontHeading);
  }
}
