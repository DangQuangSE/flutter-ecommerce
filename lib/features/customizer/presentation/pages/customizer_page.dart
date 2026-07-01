import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/constants/printing_constants.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_state.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_view_helpers.dart';

class CustomizerPage extends StatefulWidget {
  final String productId;
  final String productName;
  final int? variantId;
  final int cartQuantity;
  final double? basePrice;
  final int? customDesignId;
  final Future<void> Function(int customDesignId)? onConfirm;

  const CustomizerPage({
    super.key,
    required this.productId,
    required this.productName,
    this.variantId,
    this.cartQuantity = 1,
    this.basePrice,
    this.customDesignId,
    this.onConfirm,
  });

  @override
  State<CustomizerPage> createState() => CustomizerPageState();
}

class CustomizerPageState extends State<CustomizerPage> {
  final GlobalKey canvasKey = GlobalKey();
  final TextEditingController textController = TextEditingController();

  bool isFrontView = true;
  double zoomScale = 1.0;
  double rotationAngle = 0.0;
  String printMethod = AppStrings.customizerDefaultPrintMethod;
  final List<DesignLayer> layers = [];
  DesignLayer? activeLayer;
  bool hasRestoredExistingDesign = false;

  final List<Color> presetColors = [
    AppColors.canvasGradientStart,
    AppColors.darkText,
    AppColors.accentBlue,
    AppColors.accentOrange,
    AppColors.accentRed,
    const Color(0xFF2ECC71),
    AppColors.accentPink,
    AppColors.accentYellow,
  ];

  final List<String> fontsList = ['Lexend', 'Inter', 'Roboto', 'Montserrat'];

  @override
  void initState() {
    super.initState();
    if (widget.customDesignId == null) {
      hasRestoredExistingDesign = true;
    }
    Future.microtask(() {
      if (!mounted) return;
      context
          .read<CustomizerCubit>()
          .loadPrintingConfigs(existingDesignId: widget.customDesignId);
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void updateState(VoidCallback fn) => setState(fn);

  PrintingMaterialEntity? get selectedMaterial {
    if (context.read<CustomizerCubit>().state
        case CustomizerLoaded(:final printingConfigs)) {
      for (final material in printingConfigs.materials) {
        final materialName = material.name.toLowerCase();
        final selectedName = printMethod.toLowerCase();
        if (materialName == selectedName ||
            materialName.contains(selectedName) ||
            selectedName.contains(materialName)) {
          return material;
        }
      }
      if (printingConfigs.materials.isNotEmpty) {
        return printingConfigs.materials.first;
      }
    }
    return null;
  }

  double get printingMethodCost {
    return selectedMaterial?.basePrice ??
        (printMethod == AppStrings.customizerDefaultPrintMethod
            ? PrintingConstants.heatTransferCost
            : PrintingConstants.reflectiveDecalCost);
  }

  double get textUnitPrice {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final printingConfigs)) {
      try {
        return printingConfigs.priceConfigs
            .firstWhere((config) => config.type == 'TEXT')
            .unitPrice;
      } catch (_) {}
    }
    return 10000.0;
  }

  double get imageUnitPrice {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final printingConfigs)) {
      try {
        return printingConfigs.priceConfigs
            .firstWhere((config) => config.type == 'IMAGE')
            .unitPrice;
      } catch (_) {}
    }
    return 25000.0;
  }

  double get totalPrintingPrice {
    if (layers.isEmpty) return 0.0;
    final textLayerCount =
        layers.where((layer) => layer.type == LayerType.text).length;
    final imageLayerCount =
        layers.where((layer) => layer.type == LayerType.logo).length;
    return printingMethodCost +
        (textLayerCount * textUnitPrice) +
        (imageLayerCount * imageUnitPrice);
  }

  double get totalPrice =>
      (widget.basePrice ?? PrintingConstants.baseProductPrice) +
      totalPrintingPrice;

  List<Color> get effectiveColors {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final printingConfigs)
        when printingConfigs.colors.isNotEmpty) {
      try {
        return printingConfigs.colors
            .map((color) => parseHexColor(color.hexCode))
            .toList();
      } catch (_) {}
    }
    return presetColors;
  }

  Color parseHexColor(String hex) {
    var hexValue = hex.replaceAll('#', '');
    if (hexValue.length == 6) hexValue = 'FF$hexValue';
    return Color(int.parse(hexValue, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomizerCubit, CustomizerState>(
      listenWhen: (previous, current) =>
          !hasRestoredExistingDesign && current is CustomizerLoaded,
      listener: (context, state) {
        if (state case CustomizerLoaded(:final existingDesign)
            when existingDesign != null) {
          restoreExistingDesign(
            existingDesign.designMetadata,
            existingDesign.backDesignMetadata,
          );
          printMethod = existingDesign.printingMaterialName;
        }
        hasRestoredExistingDesign = true;
      },
      child: BlocBuilder<CustomizerCubit, CustomizerState>(
        builder: (context, state) => switch (state) {
          CustomizerLoading() => buildLoading(),
          CustomizerError(:final message) => buildError(message),
          CustomizerLoaded() => buildLoaded(),
          CustomizerSaving() => buildLoaded(isSaving: true),
          CustomizerInitial() => buildLoading(),
        },
      ),
    );
  }

  void restoreExistingDesign(String metadata, String backMetadata) {
    final restored = <DesignLayer>[];
    try {
      if (metadata.isNotEmpty) {
        final decoded = jsonDecode(metadata) as List<dynamic>;
        restored.addAll(decoded.map(
          (entry) => DesignLayer.fromJson(
            entry as Map<String, dynamic>,
          ).copyWith(view: LayerView.front),
        ));
      }
    } catch (_) {}
    try {
      if (backMetadata.isNotEmpty) {
        final decoded = jsonDecode(backMetadata) as List<dynamic>;
        restored.addAll(decoded.map(
          (entry) => DesignLayer.fromJson(
            entry as Map<String, dynamic>,
          ).copyWith(view: LayerView.back),
        ));
      }
    } catch (_) {}
    setState(() {
      layers
        ..clear()
        ..addAll(restored);
      if (restored.isNotEmpty) {
        activeLayer = restored.last;
        if (activeLayer!.type == LayerType.text) {
          textController.text = activeLayer!.text;
        }
      }
    });
  }
}
