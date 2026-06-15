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
    context
        .read<CustomizerCubit>()
        .loadPrintingConfigs(existingDesignId: widget.customDesignId);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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

  void _addNewTextLayer() {
    setState(() {
      final offset = (_layers.length % 4) * 0.1 - 0.15;
      final newLayer = DesignLayer(
        id: 'layer-${DateTime.now().millisecondsSinceEpoch}',
        type: LayerType.text,
        text: 'LỚP CHỮ MỚI',
        color: AppColors.accentRed,
        fontSize: AppSizes.fontXxl,
        x: offset,
        y: offset,
      );
      _layers.add(newLayer);
      _activeLayer = newLayer;
      _textController.text = newLayer.text;
    });
  }

  Future<void> _uploadLogo() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          final newLayer = DesignLayer(
            id: 'layer-${DateTime.now().millisecondsSinceEpoch}',
            type: LayerType.logo,
            logoPath: image.path,
            y: -0.3,
          );
          _layers.add(newLayer);
          _activeLayer = newLayer;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Không thể tải ảnh. Vui lòng kiểm tra quyền truy cập thư viện.')),
        );
      }
    }
  }

  void _handleReset() {
    setState(() {
      _layers.clear();
      _activeLayer = null;
      _textController.clear();
      _printMethod = 'In chuyển nhiệt';
      _zoomScale = 1.0;
      _rotationAngle = 0.0;
      _isFrontView = true;
      _addDefaultLayer();
    });
  }

  void _addDefaultLayer() {
    final defaultLayer = DesignLayer(
      id: 'layer-default',
      type: LayerType.text,
      text: 'SPORT PRO',
      color: AppColors.accentBlue,
      fontSize: AppSizes.fontHeading,
      y: -0.1,
    );
    _layers.add(defaultLayer);
    _activeLayer = defaultLayer;
    _textController.text = defaultLayer.text;
  }

  Future<Uint8List?> _captureCanvas() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void _showColorPicker() {
    if (_activeLayer == null || _activeLayer!.type != LayerType.text) return;
    Color pickerColor = _activeLayer!.color;
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('Chọn màu sắc in',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: AppSizes.fontMd)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            child: Text('Hủy',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
            onPressed: () => ctx.pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child:
                Text('Xác nhận', style: GoogleFonts.inter(color: Colors.white)),
            onPressed: () {
              setState(() {
                _activeLayer = _activeLayer!.copyWith(color: pickerColor);
                final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
                if (idx != -1) _layers[idx] = _activeLayer!;
              });
              ctx.pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirm() async {
    final cubit = context.read<CustomizerCubit>();
    final previousActive = _activeLayer;
    setState(() => _activeLayer = null);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _captureCanvas();
    setState(() => _activeLayer = previousActive);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Không thể chụp hình thiết kế.'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final primary = _extractPrimaryTextLayer();
    final hasLogo = _layers.any((l) => l.type == LayerType.logo);
    final layersJsonStr = jsonEncode(_layers.map((l) => l.toJson()).toList());
    final materialId = _selectedMaterial?.id ??
        (_printMethod == 'In chuyển nhiệt'
            ? PrintingConstants.heatTransferId
            : PrintingConstants.reflectiveDecalId);
    final textLayersCount =
        _layers.where((l) => l.type == LayerType.text).length;
    final imagesCount = _layers.where((l) => l.type == LayerType.logo).length;

    await cubit.saveCustomization(
      productId: widget.productId,
      materialId: materialId,
      numTextLines: textLayersCount,
      numImages: imagesCount,
      metadata: layersJsonStr,
      imageBytes: bytes,
      activeText: primary.text,
      activeColor: primary.color,
      activeFontSize: primary.fontSize,
      hasLogo: hasLogo,
      printMethod: _printMethod,
      layersJson: layersJsonStr,
    );

    if (!mounted) return;

    final state = context.read<CustomizerCubit>().state;
    if (state is CustomizerLoaded) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: AppSizes.iconMd),
          AppSizes.spacingSm,
          Text('Đã lưu thiết kế lên hệ thống thành công!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ));
      if (widget.variantId != null) {
        final savedDesignId = _findSavedDesignId();
        if (savedDesignId != null) {
          await widget.onConfirm?.call(savedDesignId);
        }
      }
      if (!mounted) return;
      context.goNamed(AppRoutes.cart);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Không thể đồng bộ với server.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  int? _findSavedDesignId() {
    final state = context.read<CustomizerCubit>().state;
    if (state case CustomizerLoaded(:final savedCustomizations)) {
      return savedCustomizations[widget.productId]?.customDesignId;
    }
    return null;
  }

  ({String text, int color, double fontSize}) _extractPrimaryTextLayer() {
    final textLayers = _layers.where((l) => l.type == LayerType.text);
    if (textLayers.isNotEmpty) {
      final primary = textLayers.first;
      return (
        text: primary.text,
        color: primary.color.toARGB32(),
        fontSize: primary.fontSize
      );
    }
    return (text: '', color: 0xFF1A1C1F, fontSize: AppSizes.fontHeading);
  }

  TextStyle _getFontFamily(String fontName) {
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

  void _onFrontViewChanged(bool v) => setState(() => _isFrontView = v);
  void _onZoomChanged(double v) => setState(() => _zoomScale = v);
  void _onPrintMethodChanged(String v) => setState(() => _printMethod = v);

  void _onLayerActivatedFromCanvas(DesignLayer layer) => setState(() {
        _activeLayer = layer;
        if (layer.type == LayerType.text) {
          _textController.text = layer.text;
          _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length));
        }
      });

  void _onLayerDragged(String id, Offset delta) => setState(() {
        final idx = _layers.indexWhere((l) => l.id == id);
        if (idx == -1) return;
        final canvasWidth =
            MediaQuery.of(context).size.width * AppSizes.canvasWidthRatio;
        final canvasHeight =
            MediaQuery.of(context).size.height * AppSizes.canvasHeightRatio;
        final cur = _layers[idx];
        final newX = (cur.x + delta.dx / _zoomScale)
            .clamp(-canvasWidth * 0.40, canvasWidth * 0.40);
        final newY = (cur.y + delta.dy / _zoomScale)
            .clamp(-canvasHeight * 0.40, canvasHeight * 0.40);
        _layers[idx] = cur.copyWith(x: newX, y: newY);
        _activeLayer = _layers[idx];
      });

  void _onLayerDeletedFromCanvas(String id) => setState(() {
        _layers.removeWhere((l) => l.id == id);
        _activeLayer = null;
        _textController.clear();
      });

  void _onActiveLayerPropChanged(DesignLayer Function(DesignLayer) updater) =>
      setState(() {
        if (_activeLayer == null) return;
        _activeLayer = updater(_activeLayer!);
        final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
        if (idx != -1) _layers[idx] = _activeLayer!;
      });

  void _onPanelLayerActivated(DesignLayer layer) => setState(() {
        _activeLayer = layer;
        if (layer.type == LayerType.text) _textController.text = layer.text;
      });

  void _onPanelLayerDeleted(int index, String id) => setState(() {
        _layers.removeAt(index);
        if (_activeLayer?.id == id) {
          _activeLayer = null;
          _textController.clear();
        }
      });

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

  Widget _buildLoading() => Scaffold(
        backgroundColor: AppColors.canvasLight,
        appBar: _buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              AppSizes.spacingMd,
              Text(
                'Đang tải cấu hình in ấn...',
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

  Widget _buildError(String message) => Scaffold(
        backgroundColor: AppColors.canvasLight,
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: AppSizes.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                AppSizes.spacingMd,
                Text(
                  'Không thể tải cấu hình in ấn.',
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
                const SizedBox(height: AppSizes.paddingLg),
                ElevatedButton(
                  onPressed: () =>
                      context.read<CustomizerCubit>().loadPrintingConfigs(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildLoaded({bool isSaving = false}) => Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.canvasLight,
            appBar: _buildAppBar(context),
            body: SafeArea(
              child: Column(
                children: [
                  _buildCanvasSection(),
                  Expanded(flex: 6, child: _buildConfigPanel()),
                  PricingFooter(
                    totalPrice: _totalPrice,
                    totalPrintingPrice: _totalPrintingPrice,
                    onReset: _handleReset,
                    onConfirm: _handleConfirm,
                  ),
                ],
              ),
            ),
          ),
          if (isSaving) _buildSavingOverlay(),
        ],
      );

  Widget _buildSavingOverlay() => Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.accent)),
                AppSizes.spacingMd,
                Text('Đang lưu thiết kế lên server...',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    )),
              ],
            ),
          ),
        ),
      );

  Widget _buildConfigPanel() => DesignConfigPanel(
        printMethod: _printMethod,
        onPrintMethodChanged: _onPrintMethodChanged,
        activeLayer: _activeLayer,
        textController: _textController,
        fontsList: _fontsList,
        presetColors: _effectiveColors,
        getFontFamily: _getFontFamily,
        onTextChanged: (val) =>
            _onActiveLayerPropChanged((l) => l.copyWith(text: val)),
        onFontChanged: (val) =>
            _onActiveLayerPropChanged((l) => l.copyWith(font: val)),
        onColorSelected: (color) =>
            _onActiveLayerPropChanged((l) => l.copyWith(color: color)),
        onCustomColorTap: _showColorPicker,
        onFontSizeChanged: (val) =>
            _onActiveLayerPropChanged((l) => l.copyWith(fontSize: val)),
        onAddLayer: _addNewTextLayer,
        onUploadLogo: _uploadLogo,
        layers: _layers,
        activeLayerId: _activeLayer?.id,
        onLayerActivated: _onPanelLayerActivated,
        onLayerDeleted: _onPanelLayerDeleted,
        materials: switch (context.read<CustomizerCubit>().state) {
          CustomizerLoaded(:final printingConfigs) => printingConfigs.materials,
          _ => null,
        },
      );

  Widget _buildCanvasSection() => Expanded(
        flex: 5,
        child: CanvasWorkspace(
          canvasKey: _canvasKey,
          layers: _layers,
          activeLayerId: _activeLayer?.id,
          isFrontView: _isFrontView,
          zoomScale: _zoomScale,
          rotationAngle: _rotationAngle,
          onFrontViewChanged: _onFrontViewChanged,
          onZoomChanged: _onZoomChanged,
          onLayerActivated: _onLayerActivatedFromCanvas,
          onLayerDragged: _onLayerDragged,
          onLayerDeleted: _onLayerDeletedFromCanvas,
          getFontFamily: _getFontFamily,
        ),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              color: AppColors.borderGray.withValues(alpha: 0.3), height: 1),
        ),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.cart);
            }
          },
          icon: const Icon(Icons.close_rounded,
              color: AppColors.textPrimary, size: AppSizes.iconLg),
        ),
        title: Column(
          children: [
            Transform(
              transform: Matrix4.skewX(-0.12),
              child: Text(
                'TÙY CHỈNH THIẾT KẾ',
                style: GoogleFonts.lexend(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(widget.productName,
                style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
      );
}
