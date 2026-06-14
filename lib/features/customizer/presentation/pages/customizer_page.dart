import 'dart:convert';
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
import 'package:flutter_ecommerce/core/constants/printing_constants.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/customization_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/canvas_workspace.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/design_config_panel.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/pricing_footer.dart';

class CustomizerPage extends StatefulWidget {
  final String productId;
  final String productName;
  final int? variantId;
  final int cartQuantity;
  final Future<void> Function(int customDesignId)? onConfirm;

  const CustomizerPage({
    super.key,
    required this.productId,
    required this.productName,
    this.variantId,
    this.cartQuantity = 1,
    this.onConfirm,
  });

  @override
  State<CustomizerPage> createState() => _CustomizerPageState();
}

class _CustomizerPageState extends State<CustomizerPage> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSaving = false;
  bool _isInitialized = false;

  // Canvas state
  bool _isFrontView = true;
  double _zoomScale = 1.0;
  double _rotationAngle = 0.0;

  // Design state
  String _printMethod = 'In chuyển nhiệt';
  final List<DesignLayer> _layers = [];
  DesignLayer? _activeLayer;
  late TextEditingController _textController;
  final ImagePicker _imagePicker = ImagePicker();

  // Constants for the config panel
  final List<Color> _presetColors = [
    const Color(0xFFFFFFFF),
    const Color(0xFF1A1C1F),
    const Color(0xFF0058BC),
    const Color(0xFFFE9400),
    const Color(0xFFBA1A1A),
    const Color(0xFF2ECC71),
    const Color(0xFFEC407A),
    const Color(0xFFFFEB3B),
  ];

  final List<String> _fontsList = ['Lexend', 'Inter', 'Roboto', 'Montserrat'];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeCustomizer();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initializeCustomizer() {
    final cubit = context.read<CustomizerCubit>();
    final saved = cubit.getCustomizationOrDefault(widget.productId);
    _printMethod = saved.printMethod;

    final double maxHOffset = MediaQuery.of(context).size.width * 0.85 * 0.35;
    final double maxVOffset = MediaQuery.of(context).size.height * 0.42 * 0.25;

    if (saved.layersJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(saved.layersJson);
        final restored = decoded.map((e) {
          var layer = DesignLayer.fromJson(e as Map<String, dynamic>);
          if (layer.x.abs() <= 1.0 && layer.y.abs() <= 1.0 && (layer.x != 0.0 || layer.y != 0.0)) {
            layer = layer.copyWith(x: layer.x * maxHOffset, y: layer.y * maxVOffset);
          }
          return layer;
        }).toList();
        _layers.addAll(restored);
        if (_layers.isNotEmpty) {
          _activeLayer = _layers.last;
          if (_activeLayer!.type == LayerType.text) {
            _textController.text = _activeLayer!.text;
          }
        }
      } catch (e) {
        debugPrint('Error restoring layers: $e');
      }
    } else if (saved.customText.isNotEmpty && saved.customText != 'TEAM SPORT') {
      final initialLayer = DesignLayer(
        id: 'layer-${DateTime.now().millisecondsSinceEpoch}',
        type: LayerType.text,
        text: saved.customText,
        color: Color(saved.colorHex),
        fontSize: (22.0 * saved.textScale).clamp(12.0, 60.0),
        y: -0.1 * maxVOffset,
      );
      _layers.add(initialLayer);
      _activeLayer = initialLayer;
      _textController.text = initialLayer.text;
    } else {
      final defaultLayer = DesignLayer(
        id: 'layer-default',
        type: LayerType.text,
        text: 'SPORT PRO',
        color: const Color(0xFF0058BC),
        fontSize: 22.0,
        y: -0.1 * maxVOffset,
      );
      _layers.add(defaultLayer);
      _activeLayer = defaultLayer;
      _textController.text = defaultLayer.text;
    }
  }

  double get _printingMethodCost => _printMethod == 'In chuyển nhiệt'
      ? PrintingConstants.heatTransferCost
      : PrintingConstants.reflectiveDecalCost;

  double get _extraLayersCost => _layers.length * PrintingConstants.extraLayerCost;
  double get _totalPrintingPrice => _printingMethodCost + _extraLayersCost;
  double get _totalPrice => PrintingConstants.baseProductPrice + _totalPrintingPrice;

  void _addNewTextLayer() {
    setState(() {
      final double offset = (_layers.length % 4) * 0.1 - 0.15;
      final newLayer = DesignLayer(
        id: 'layer-${DateTime.now().millisecondsSinceEpoch}',
        type: LayerType.text,
        text: 'LỚP CHỮ MỚI',
        color: const Color(0xFFBA1A1A),
        fontSize: 18.0,
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
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
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
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải ảnh. Vui lòng kiểm tra quyền truy cập thư viện.')),
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
      final defaultLayer = DesignLayer(
        id: 'layer-default',
        type: LayerType.text,
        text: 'SPORT PRO',
        color: const Color(0xFF0058BC),
        fontSize: 22.0,
        y: -0.1,
      );
      _layers.add(defaultLayer);
      _activeLayer = defaultLayer;
      _textController.text = defaultLayer.text;
    });
  }

  Future<Uint8List?> _captureCanvas() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing canvas: $e');
      return null;
    }
  }

  Future<void> _handleConfirm() async {
    setState(() { _isSaving = true; });
    final previousActiveLayer = _activeLayer;
    setState(() { _activeLayer = null; });
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _captureCanvas();
    if (bytes == null) {
      setState(() { _activeLayer = previousActiveLayer; _isSaving = false; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chụp hình thiết kế. Vui lòng thử lại!'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() { _activeLayer = previousActiveLayer; });

    String activeText = '';
    int activeColor = 0xFF1A1C1F;
    double activeFontSize = 22.0;
    final textLayers = _layers.where((l) => l.type == LayerType.text);
    if (textLayers.isNotEmpty) {
      final primary = textLayers.first;
      activeText = primary.text;
      activeColor = primary.color.toARGB32();
      activeFontSize = primary.fontSize;
    }

    final hasLogo = _layers.any((l) => l.type == LayerType.logo);
    final layersJsonStr = jsonEncode(_layers.map((l) => l.toJson()).toList());
    final int materialId = _printMethod == 'In chuyển nhiệt' ? PrintingConstants.heatTransferId : PrintingConstants.reflectiveDecalId;

    final result = await sl<CustomDesignRepository>().saveDesign(
      materialId: materialId,
      numTextLines: textLayers.length,
      numImages: _layers.where((l) => l.type == LayerType.logo).length,
      metadata: layersJsonStr,
      imageBytes: bytes,
    );

    setState(() => _isSaving = false);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        final customDesignId = data;
        await context.read<CustomizerCubit>().saveCustomization(
          widget.productId,
          CustomizationEntity(
            productId: widget.productId,
            customText: activeText,
            textColor: 'Selected Color',
            colorHex: activeColor,
            printMethod: _printMethod,
            logoEnabled: hasLogo,
            textScale: activeFontSize / 22.0,
            layersJson: layersJsonStr,
            customDesignId: customDesignId,
          ),
        );
        if (widget.variantId != null) {
          await widget.onConfirm?.call(customDesignId);
          if (!mounted) return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Đã lưu thiết kế lên hệ thống thành công!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ));
        if (context.canPop()) context.pop(); else context.goNamed(AppRoutes.cart);
      case ResultFailure(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Không thể đồng bộ với server: ${failure.message}'),
          backgroundColor: AppColors.error,
        ));
    }
  }

  void _showColorPicker() {
    if (_activeLayer == null || _activeLayer!.type != LayerType.text) return;
    Color pickerColor = _activeLayer!.color;
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('Chọn màu sắc in', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) { pickerColor = c; },
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            child: Text('Hủy', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            onPressed: () => ctx.pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Xác nhận', style: GoogleFonts.inter(color: Colors.white)),
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

  TextStyle _getFontFamily(String fontName) {
    switch (fontName) {
      case 'Lexend': return GoogleFonts.lexend();
      case 'Inter': return GoogleFonts.inter();
      case 'Roboto': return GoogleFonts.roboto();
      case 'Montserrat': return GoogleFonts.montserrat();
      default: return GoogleFonts.inter();
    }
  }

  // ── Simple state setters ──────────────────────────────────────────────────
  void _onFrontViewChanged(bool v) => setState(() => _isFrontView = v);
  void _onZoomChanged(double v) => setState(() => _zoomScale = v);
  void _onPrintMethodChanged(String v) => setState(() => _printMethod = v);

  // ── Canvas callbacks ──────────────────────────────────────────────────────
  void _onLayerActivatedFromCanvas(DesignLayer layer) => setState(() {
    _activeLayer = layer;
    if (layer.type == LayerType.text) {
      _textController.text = layer.text;
      _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
    }
  });

  void _onLayerDragged(String id, Offset delta) => setState(() {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final canvasWidth = MediaQuery.of(context).size.width * 0.85;
    final canvasHeight = MediaQuery.of(context).size.height * 0.42;
    final cur = _layers[idx];
    final newX = (cur.x + delta.dx / _zoomScale).clamp(-canvasWidth * 0.40, canvasWidth * 0.40);
    final newY = (cur.y + delta.dy / _zoomScale).clamp(-canvasHeight * 0.40, canvasHeight * 0.40);
    _layers[idx] = cur.copyWith(x: newX, y: newY);
    _activeLayer = _layers[idx];
  });

  void _onLayerDeletedFromCanvas(String id) => setState(() {
    _layers.removeWhere((l) => l.id == id);
    _activeLayer = null;
    _textController.clear();
  });

  // ── Config panel callbacks ─────────────────────────────────────────────────
  void _onActiveLayerPropChanged(DesignLayer Function(DesignLayer) updater) => setState(() {
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
    if (_activeLayer?.id == id) { _activeLayer = null; _textController.clear(); }
  });

  Widget _buildSavingOverlay() => Positioned.fill(
    child: Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent)),
            const SizedBox(height: 16),
            Text('Đang lưu thiết kế lên server...', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF3F3F8),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: Column(
              children: [
                _buildCanvasSection(),
                Expanded(
                  flex: 6,
                  child: DesignConfigPanel(
                    printMethod: _printMethod,
                    onPrintMethodChanged: _onPrintMethodChanged,
                    activeLayer: _activeLayer,
                    textController: _textController,
                    fontsList: _fontsList,
                    presetColors: _presetColors,
                    getFontFamily: _getFontFamily,
                    onTextChanged: (val) => _onActiveLayerPropChanged((l) => l.copyWith(text: val)),
                    onFontChanged: (val) => _onActiveLayerPropChanged((l) => l.copyWith(font: val)),
                    onColorSelected: (color) => _onActiveLayerPropChanged((l) => l.copyWith(color: color)),
                    onCustomColorTap: _showColorPicker,
                    onFontSizeChanged: (val) => _onActiveLayerPropChanged((l) => l.copyWith(fontSize: val)),
                    onAddLayer: _addNewTextLayer,
                    onUploadLogo: _uploadLogo,
                    layers: _layers,
                    activeLayerId: _activeLayer?.id,
                    onLayerActivated: _onPanelLayerActivated,
                    onLayerDeleted: _onPanelLayerDeleted,
                  ),
                ),
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
        if (_isSaving) _buildSavingOverlay(),
      ],
    );
  }

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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFC1C6D7).withValues(alpha: 0.3), height: 1),
      ),
      leading: IconButton(
        onPressed: () { if (context.canPop()) context.pop(); else context.goNamed(AppRoutes.cart); },
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 24),
      ),
      title: Column(
        children: [
          Transform(
            transform: Matrix4.skewX(-0.12),
            child: Text(
              'TÙY CHỈNH THIẾT KẾ',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: AppColors.textPrimary, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(widget.productName, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
      centerTitle: true,
    );
  }
}
