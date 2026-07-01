import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_page.dart';

extension CustomizerLayerHandlers on CustomizerPageState {
  TextStyle getFontFamily(String fontName) {
    switch (fontName) {
      case 'Lexend':
        return GoogleFonts.lexend();
      case 'Inter':
        return GoogleFonts.inter();
      case 'Roboto':
        return GoogleFonts.roboto();
      case 'Montserrat':
        return GoogleFonts.montserrat();
      default:
        return GoogleFonts.inter();
    }
  }

  void onFrontViewChanged(bool value) {
    updateState(() => isFrontView = value);
  }

  void onZoomChanged(double value) {
    updateState(() => zoomScale = value);
  }

  void onPrintMethodChanged(String value) {
    updateState(() => printMethod = value);
  }

  void onLayerActivatedFromCanvas(DesignLayer layer) {
    updateState(() {
      activeLayer = layer;
      if (layer.type == LayerType.text) {
        textController.text = layer.text;
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
      }
    });
  }

  void onLayerDragged(String id, Offset delta) {
    updateState(() {
      final index = layers.indexWhere((layer) => layer.id == id);
      if (index == -1) return;

      final canvasWidth =
          MediaQuery.of(context).size.width * AppSizes.canvasWidthRatio;
      final canvasHeight =
          MediaQuery.of(context).size.height * AppSizes.canvasHeightRatio;
      final currentLayer = layers[index];
      final newX = (currentLayer.x + delta.dx / zoomScale).clamp(
        -canvasWidth * AppSizes.canvasMaxOffsetRatio,
        canvasWidth * AppSizes.canvasMaxOffsetRatio,
      );
      final newY = (currentLayer.y + delta.dy / zoomScale).clamp(
        -canvasHeight * AppSizes.canvasMaxOffsetRatio,
        canvasHeight * AppSizes.canvasMaxOffsetRatio,
      );

      layers[index] = currentLayer.copyWith(x: newX, y: newY);
      activeLayer = layers[index];
    });
  }

  void onLayerDeletedFromCanvas(String id) {
    updateState(() {
      layers.removeWhere((layer) => layer.id == id);
      activeLayer = null;
      textController.clear();
    });
  }

  void onActiveLayerPropChanged(DesignLayer Function(DesignLayer) updater) {
    updateState(() {
      if (activeLayer == null) return;
      activeLayer = updater(activeLayer!);
      final index = layers.indexWhere((layer) => layer.id == activeLayer!.id);
      if (index != -1) layers[index] = activeLayer!;
    });
  }

  void onPanelLayerActivated(DesignLayer layer) {
    updateState(() {
      activeLayer = layer;
      if (layer.type == LayerType.text) textController.text = layer.text;
    });
  }

  void onPanelLayerDeleted(int index, String id) {
    updateState(() {
      layers.removeAt(index);
      if (activeLayer?.id == id) {
        activeLayer = null;
        textController.clear();
      }
    });
  }
}
