import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/printing_constants.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_state.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/canvas_workspace.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/design_config_panel.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/pricing_footer.dart';

part 'customizer_actions.dart';
part 'customizer_layer_handlers.dart';
part 'customizer_view_helpers.dart';

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
  State<CustomizerPage> createState() => _CustomizerPageState();
}

class _CustomizerPageState extends State<CustomizerPage> {
  final GlobalKey _canvasKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isFrontView = true;
  double _zoomScale = 1.0;
  double _rotationAngle = 0.0;
  String _printMethod = 'In chuyển nhiệt';
  final List<DesignLayer> _layers = [];
  DesignLayer? _activeLayer;
  bool _hasRestoredExistingDesign = false;

  final List<Color> _presetColors = [
    AppColors.canvasGradientStart,
    AppColors.darkText,
    AppColors.accentBlue,
    AppColors.accentOrange,
    AppColors.accentRed,
    const Color(0xFF2ECC71),
    AppColors.accentPink,
    AppColors.accentYellow,
  ];

  final List<String> _fontsList = ['Lexend', 'Inter', 'Roboto', 'Montserrat'];

  @override
  void initState() {
    super.initState();
    if (widget.customDesignId == null) {
      _hasRestoredExistingDesign = true;
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
    _textController.dispose();
    super.dispose();
  }

  void _updateState(VoidCallback fn) => setState(fn);

  PrintingMaterialEntity? get _selectedMaterial {
    if (context.read<CustomizerCubit>().state
        case CustomizerLoaded(:final printingConfigs)) {
      for (final m in printingConfigs.materials) {
        if (m.name.toLowerCase() == _printMethod.toLowerCase() ||
            m.name.toLowerCase().contains(_printMethod.toLowerCase()) ||
            _printMethod.toLowerCase().contains(m.name.toLowerCase())) {
          return m;
        }
      }
      if (printingConfigs.materials.isNotEmpty) {
        return printingConfigs.materials.first;
      }
    }
    return null;
  }

  double get _printingMethodCost {
    return _selectedMaterial?.basePrice ??
        (_printMethod == 'In chuyển nhiệt'
            ? PrintingConstants.heatTransferCost
            : PrintingConstants.reflectiveDecalCost);
  }

  double get _textUnitPrice {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final printingConfigs)) {
      try {
        return printingConfigs.priceConfigs
            .firstWhere((c) => c.type == 'TEXT')
            .unitPrice;
      } catch (_) {}
    }
    return 10000.0;
  }

  double get _imageUnitPrice {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final printingConfigs)) {
      try {
        return printingConfigs.priceConfigs
            .firstWhere((c) => c.type == 'IMAGE')
            .unitPrice;
      } catch (_) {}
    }
    return 25000.0;
  }

  double get _totalPrintingPrice {
    if (_layers.isEmpty) return 0.0;
    final numTextLines = _layers.where((l) => l.type == LayerType.text).length;
    final numImages = _layers.where((l) => l.type == LayerType.logo).length;
    return _printingMethodCost +
        (numTextLines * _textUnitPrice) +
        (numImages * _imageUnitPrice);
  }

  double get _totalPrice =>
      (widget.basePrice ?? PrintingConstants.baseProductPrice) +
      _totalPrintingPrice;

  List<Color> get _effectiveColors {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final printingConfigs)
        when printingConfigs.colors.isNotEmpty) {
      try {
        return printingConfigs.colors
            .map((c) => _parseHexColor(c.hexCode))
            .toList();
      } catch (_) {}
    }
    return _presetColors;
  }

  Color _parseHexColor(String hex) {
    var hexStr = hex.replaceAll('#', '');
    if (hexStr.length == 6) hexStr = 'FF$hexStr';
    return Color(int.parse(hexStr, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomizerCubit, CustomizerState>(
      listenWhen: (prev, curr) =>
          !_hasRestoredExistingDesign && curr is CustomizerLoaded,
      listener: (context, state) {
        if (state case CustomizerLoaded(:final existingDesign)
            when existingDesign != null) {
          final metadata = existingDesign.designMetadata;
          if (metadata.isNotEmpty) {
            try {
              final List<dynamic> decoded =
                  jsonDecode(metadata) as List<dynamic>;
              final restored = decoded
                  .map((e) => DesignLayer.fromJson(e as Map<String, dynamic>))
                  .toList();
              setState(() {
                _layers
                  ..clear()
                  ..addAll(restored);
                if (restored.isNotEmpty) {
                  _activeLayer = restored.last;
                  if (_activeLayer!.type == LayerType.text) {
                    _textController.text = _activeLayer!.text;
                  }
                }
                _printMethod = existingDesign.printingMaterialName;
              });
            } catch (_) {}
          }
        }
        _hasRestoredExistingDesign = true;
      },
      child: BlocBuilder<CustomizerCubit, CustomizerState>(
        builder: (context, state) => switch (state) {
          CustomizerLoading() => _buildLoading(),
          CustomizerError(:final message) => _buildError(message),
          CustomizerLoaded() => _buildLoaded(),
          CustomizerSaving() => _buildLoaded(isSaving: true),
          CustomizerInitial() => _buildLoading(),
        },
      ),
    );
  }
}
