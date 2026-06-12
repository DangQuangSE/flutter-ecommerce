import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/customization_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/custom_design_repository.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/customizer_cubit.dart';

enum LayerType { text, logo }

class DesignLayer {
  final String id;
  final LayerType type;
  final String text;
  final String font;
  final Color color;
  final double fontSize;
  final double x;
  final double y;
  final String? logoPath;

  DesignLayer({
    required this.id,
    required this.type,
    this.text = '',
    this.font = 'Lexend',
    this.color = const Color(0xFF0058BC),
    this.fontSize = 20.0,
    this.x = 0.0,
    this.y = 0.0,
    this.logoPath,
  });

  DesignLayer copyWith({
    String? text,
    String? font,
    Color? color,
    double? fontSize,
    double? x,
    double? y,
    String? logoPath,
  }) {
    return DesignLayer(
      id: id,
      type: type,
      text: text ?? this.text,
      font: font ?? this.font,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      x: x ?? this.x,
      y: y ?? this.y,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'font': font,
        'color': color.toARGB32(),
        'fontSize': fontSize,
        'x': x,
        'y': y,
        'logoPath': logoPath,
      };

  factory DesignLayer.fromJson(Map<String, dynamic> json) => DesignLayer(
        id: json['id'] as String,
        type: LayerType.values.byName(json['type'] as String),
        text: json['text'] as String? ?? '',
        font: json['font'] as String? ?? 'Lexend',
        color: Color(json['color'] as int),
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20.0,
        x: (json['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['y'] as num?)?.toDouble() ?? 0.0,
        logoPath: json['logoPath'] as String?,
      );
}

class ProductCustomizerPage extends StatefulWidget {
  final String productId;
  final String productName;
  final int? variantId;
  final int cartQuantity;

  const ProductCustomizerPage({
    super.key,
    required this.productId,
    required this.productName,
    this.variantId,
    this.cartQuantity = 1,
  });

  @override
  State<ProductCustomizerPage> createState() => _ProductCustomizerPageState();
}

class _ProductCustomizerPageState extends State<ProductCustomizerPage> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSaving = false;
  
  // Core config states
  String _printMethod = 'In chuyển nhiệt'; // 'In chuyển nhiệt' or 'Decal phản quang'
  bool _isFrontView = true;

  // Canvas utility states
  double _zoomScale = 1.0;
  double _rotationAngle = 0.0;

  // Layers state
  final List<DesignLayer> _layers = [];
  DesignLayer? _activeLayer;

  late TextEditingController _textController;
  final ImagePicker _imagePicker = ImagePicker();

  // Preset Colors
  final List<Color> _presetColors = [
    const Color(0xFFFFFFFF), // White
    const Color(0xFF1A1C1F), // Jet Black
    const Color(0xFF0058BC), // Electric Blue
    const Color(0xFFFE9400), // Safety Orange
    const Color(0xFFBA1A1A), // Crimson Red
    const Color(0xFF2ECC71), // Forest Green
    const Color(0xFFEC407A), // Hot Pink
    const Color(0xFFFFEB3B), // Yellow
  ];

  // Font Styles List
  final List<String> _fontsList = [
    'Lexend',
    'Inter',
    'Roboto',
    'Montserrat',
  ];

  bool _isInitialized = false;

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

  void _initializeCustomizer() {
    // Load saved customization layers
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
          // If coordinates are in normalized form, convert them to pixels
          if (layer.x.abs() <= 1.0 && layer.y.abs() <= 1.0 && (layer.x != 0.0 || layer.y != 0.0)) {
            layer = layer.copyWith(
              x: layer.x * maxHOffset,
              y: layer.y * maxVOffset,
            );
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
      // Add default team text layer to welcome user
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  double get _basePrice => 40050.0;

  double get _printingMethodCost {
    return _printMethod == 'In chuyển nhiệt' ? 30000.0 : 50000.0;
  }

  double get _extraLayersCost {
    return (_layers.length) * 10000.0;
  }

  double get _totalPrintingPrice => _printingMethodCost + _extraLayersCost;

  double get _totalPrice => _basePrice + _totalPrintingPrice;

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
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
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

      // Add a fresh default layer
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
    // 1. Capture design image bytes
    setState(() => _isSaving = true);
    
    // De-activate current layer to hide borders/close buttons from the screenshot
    final previousActiveLayer = _activeLayer;
    setState(() {
      _activeLayer = null;
    });

    // Wait a frame for UI to repaint without active layer borders
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _captureCanvas();
    if (bytes == null) {
      setState(() {
        _activeLayer = previousActiveLayer;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chụp hình thiết kế. Vui lòng thử lại!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Restore active layer
    setState(() {
      _activeLayer = previousActiveLayer;
    });

    // 2. Prepare request data
    String activeText = '';
    int activeColor = 0xFF1A1C1F;
    double activeFontSize = 22.0;

    final textLayers = _layers.where((l) => l.type == LayerType.text);
    if (textLayers.isNotEmpty) {
      final primaryText = textLayers.first;
      activeText = primaryText.text;
      activeColor = primaryText.color.toARGB32();
      activeFontSize = primaryText.fontSize;
    }

    final hasLogo = _layers.any((l) => l.type == LayerType.logo);
    final layersJsonStr = jsonEncode(_layers.map((l) => l.toJson()).toList());

    final int materialId = _printMethod == 'In chuyển nhiệt' ? 1 : 2;
    final int numTextLines = textLayers.length;
    final int numImages = _layers.where((l) => l.type == LayerType.logo).length;

    // 3. Upload to backend
    final repository = sl<CustomDesignRepository>();
    final result = await repository.saveDesign(
      materialId: materialId,
      numTextLines: numTextLines,
      numImages: numImages,
      metadata: layersJsonStr,
      imageBytes: bytes,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        final customDesignId = data;
        
        // Save the customization entity locally with the customDesignId from backend
        final customization = CustomizationEntity(
          productId: widget.productId,
          customText: activeText,
          textColor: 'Selected Color',
          colorHex: activeColor,
          printMethod: _printMethod,
          logoEnabled: hasLogo,
          textScale: activeFontSize / 22.0,
          layersJson: layersJsonStr,
          customDesignId: customDesignId,
        );

        await context.read<CustomizerCubit>().saveCustomization(widget.productId, customization);

        // Link design to cart item so backend includes printingPrice in itemTotal
        if (widget.variantId != null) {
          // Capture old item ID (same variant, no design) before adding new one
          int? oldItemId;
          final cartState = sl<CartCubit>().state;
          if (cartState is CartLoaded) {
            final candidates = cartState.items.where(
              (item) => item.variantId == widget.variantId! && item.customDesignId == null,
            );
            if (candidates.isNotEmpty) oldItemId = candidates.first.itemId;
          }

          // Add new item with design (backend calculates itemTotal + printingPrice)
          await sl<CartCubit>().addItem(
            variantId: widget.variantId!,
            quantity: widget.cartQuantity,
            isReplace: true,
            customDesignId: customDesignId,
          );
          if (!mounted) return;

          // Remove old item without design to avoid duplicates
          if (oldItemId != null) {
            await sl<CartCubit>().removeItem(oldItemId);
            if (!mounted) return;
          }
        }

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Đã lưu thiết kế lên hệ thống thành công!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(AppRoutes.cart);
        }
        break;
        
      case ResultFailure(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể đồng bộ với server: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
        break;
    }
  }

  void _showColorPicker() {
    if (_activeLayer == null || _activeLayer!.type != LayerType.text) return;

    Color pickerColor = _activeLayer!.color;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chọn màu sắc in',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              labelTypes: [],
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy', style: GoogleFonts.inter(color: AppColors.textSecondary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Xác nhận', style: GoogleFonts.inter(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _activeLayer = _activeLayer!.copyWith(color: pickerColor);
                  final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
                  if (idx != -1) {
                    _layers[idx] = _activeLayer!;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            // 1. Zoomable & Rotatable Design Canvas Workspace
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Studio radial gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFE8E8EE),
                        ],
                      ),
                    ),
                  ),

                  // The Interactive Customizer T-Shirt Mockup
                  Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(_zoomScale)
                        ..rotateZ(_rotationAngle),
                      child: RepaintBoundary(
                        key: _canvasKey,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.height * 0.42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // White shirt template model
                              AnimatedRotation(
                                turns: _isFrontView ? 0.0 : 0.5, // Subtle visual indicator
                                duration: const Duration(milliseconds: 300),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAg16llodl6Hl8MPqH6DvSysphHsH9azINDafCIQFp9rqCHyIEj5IyNuBfAVIK7-s1m70zLJYYuRDn7ps4e9BkxeY1wfIJ58BidKV1GgULrOntZ7svsuNpwj8nvPhazvHISS-5OqI81qGvWmbwLlQlDr7PaeNVO1DpmYgljTca2s33rrrPqLBq7MLlaEkQdj7fqz_fN5K-XrOluv8Ux-V0w9V8-aE1C5t5BlJtTl7b0-7Tot4btl19oWsO5WWVz6wdqu1TcpvcIJ6k',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // Flip side indicator badge overlay
                              if (!_isFrontView)
                                Positioned(
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'MẶT SAU (BACK VIEW)',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                              // Overlay layers on the chest area
                              ..._layers.map((layer) {
                                final bool isActive = _activeLayer?.id == layer.id;
                                final double canvasWidth = MediaQuery.of(context).size.width * 0.85;
                                final double canvasHeight = MediaQuery.of(context).size.height * 0.42;

                                return Positioned(
                                  left: (canvasWidth / 2) + layer.x,
                                  top: (canvasHeight / 2) + layer.y,
                                  child: FractionalTranslation(
                                    translation: const Offset(-0.5, -0.5),
                                    child: GestureDetector(
                                      onTapDown: (_) {
                                        setState(() {
                                          _activeLayer = layer;
                                          if (layer.type == LayerType.text) {
                                            _textController.text = layer.text;
                                            _textController.selection = TextSelection.fromPosition(
                                              TextPosition(offset: _textController.text.length),
                                            );
                                          }
                                        });
                                      },
                                      onPanStart: (_) {
                                        setState(() {
                                          _activeLayer = layer;
                                          if (layer.type == LayerType.text) {
                                            _textController.text = layer.text;
                                            _textController.selection = TextSelection.fromPosition(
                                              TextPosition(offset: _textController.text.length),
                                            );
                                          }
                                        });
                                      },
                                      onPanUpdate: (details) {
                                        setState(() {
                                          final idx = _layers.indexWhere((l) => l.id == layer.id);
                                          if (idx == -1) return;
                                          final current = _layers[idx];
                                          
                                          // Clamp movement within printable area bounds (40% width, 40% height of canvas)
                                          final double maxH = canvasWidth * 0.40;
                                          final double maxV = canvasHeight * 0.40;
                                          final double newX = (current.x + details.delta.dx / _zoomScale).clamp(-maxH, maxH);
                                          final double newY = (current.y + details.delta.dy / _zoomScale).clamp(-maxV, maxV);
                                          
                                          _layers[idx] = current.copyWith(x: newX, y: newY);
                                          _activeLayer = _layers[idx];
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isActive ? AppColors.primary : Colors.transparent,
                                            width: 1.5,
                                            style: BorderStyle.solid,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            if (layer.type == LayerType.text)
                                              Transform(
                                                alignment: Alignment.center,
                                                transform: Matrix4.skewX(-0.15),
                                                child: Text(
                                                  layer.text.toUpperCase(),
                                                  style: _getFontFamily(layer.font).copyWith(
                                                    fontSize: layer.fontSize,
                                                    fontWeight: FontWeight.w900,
                                                    fontStyle: FontStyle.italic,
                                                    color: layer.color,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                              ),
                                            if (layer.type == LayerType.logo)
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: !kIsWeb && layer.logoPath != null
                                                    ? Image.file(
                                                        File(layer.logoPath!),
                                                        fit: BoxShape.circle == BoxShape.circle ? BoxFit.cover : BoxFit.contain,
                                                      )
                                                    : const Icon(Icons.sports_soccer_rounded, size: 28),
                                              ),
                                            if (isActive)
                                              Positioned(
                                                top: -16,
                                                right: -16,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _layers.removeWhere((l) => l.id == layer.id);
                                                      _activeLayer = null;
                                                      _textController.clear();
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(color: Colors.black12, blurRadius: 4),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.close_rounded,
                                                      size: 12,
                                                      color: AppColors.error,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (isActive)
                                              Positioned(
                                                bottom: -16,
                                                right: -16,
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.open_in_full_rounded,
                                                    size: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Canvas adjustment tool panel (Top Right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_in_rounded),
                            color: AppColors.textPrimary,
                            onPressed: () {
                              setState(() {
                                if (_zoomScale < 1.6) _zoomScale += 0.1;
                              });
                            },
                          ),
                          Container(width: 20, height: 1, color: const Color(0xFFEDEDF2)),
                          IconButton(
                            icon: const Icon(Icons.zoom_out_rounded),
                            color: AppColors.textPrimary,
                            onPressed: () {
                              setState(() {
                                if (_zoomScale > 0.7) _zoomScale -= 0.1;
                              });
                            },
                          ),
                          Container(width: 20, height: 1, color: const Color(0xFFEDEDF2)),
                          IconButton(
                            icon: const Icon(Icons.restart_alt_rounded),
                            color: AppColors.textPrimary,
                            onPressed: () {
                              setState(() {
                                _zoomScale = 1.0;
                                _rotationAngle = 0.0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Front / Back View Switch (Bottom center of canvas)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isFrontView = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isFrontView ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'MẶT TRƯỚC',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _isFrontView ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isFrontView = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_isFrontView ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'MẶT SAU',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: !_isFrontView ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Configuration Options (Scrollable panel)
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -2)),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'TÙY CHỈNH THIẾT KẾ',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tự tay thiết kế áo thi đấu đẳng cấp cao. Tên, số áo và logo tùy chỉnh theo ý bạn.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Printing Material
                      Text(
                        'CHẤT LIỆU IN ẤN',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMaterialCard(
                        title: 'In chuyển nhiệt',
                        priceAdd: '+30.000 ₫',
                        desc: 'Bền màu, phẳng mịn, phù hợp thiết kế nhiều màu sắc phức tạp.',
                      ),
                      const SizedBox(height: 10),
                      _buildMaterialCard(
                        title: 'Decal phản quang',
                        priceAdd: '+50.000 ₫',
                        desc: 'Màu sắc nổi bật, độ bền cao, phù hợp in tên và số áo phát sáng.',
                      ),
                      const SizedBox(height: 24),

                      // Section: Edit Text Layer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CHỈNH SỬA CHỮ / SỐ',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addNewTextLayer,
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: Text(
                              'THÊM LỚP MỚI',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Text input field for the active layer
                      if (_activeLayer != null && _activeLayer!.type == LayerType.text) ...[
                        Text(
                          'NỘI DUNG LỚP CHỮ',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _textController,
                          onChanged: (val) {
                            setState(() {
                              _activeLayer = _activeLayer!.copyWith(text: val);
                              final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
                              if (idx != -1) {
                                _layers[idx] = _activeLayer!;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF3F3F8),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Font dropdown selector
                        Text(
                          'FONT CHỮ',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _activeLayer!.font,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                              items: _fontsList.map((String font) {
                                return DropdownMenuItem<String>(
                                  value: font,
                                  child: Text(
                                    '$font (Thể thao)',
                                    style: _getFontFamily(font).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                if (val != null) {
                                  setState(() {
                                    _activeLayer = _activeLayer!.copyWith(font: val);
                                    final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
                                    if (idx != -1) {
                                      _layers[idx] = _activeLayer!;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Colors list + Rainbow Custom Color Picker
                        Text(
                          'MÀU SẮC IN',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _presetColors.length + 1,
                            itemBuilder: (context, idx) {
                              if (idx == _presetColors.length) {
                                // Rainbow color picker circle
                                return GestureDetector(
                                  onTap: _showColorPicker,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(
                                        colors: [
                                          Colors.red,
                                          Colors.orange,
                                          Colors.yellow,
                                          Colors.green,
                                          Colors.blue,
                                          Colors.purple,
                                          Colors.red,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(Icons.colorize_rounded, size: 16, color: Colors.white),
                                  ),
                                );
                              }

                              final color = _presetColors[idx];
                              final isSelected = _activeLayer!.color.toARGB32() == color.toARGB32();

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activeLayer = _activeLayer!.copyWith(color: color);
                                    final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
                                    if (idx != -1) {
                                      _layers[idx] = _activeLayer!;
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : const Color(0xFFC1C6D7).withValues(alpha: 0.5),
                                      width: isSelected ? 3.0 : 1.0,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: color == Colors.white ? Colors.black : Colors.white,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Font size scale slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CỠ CHỮ',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${_activeLayer!.fontSize.toInt()}px',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _activeLayer!.fontSize,
                          min: 12,
                          max: 60,
                          activeColor: AppColors.primary,
                          inactiveColor: const Color(0xFFF3F3F8),
                          onChanged: (val) {
                            setState(() {
                              _activeLayer = _activeLayer!.copyWith(fontSize: val);
                              final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
                              if (idx != -1) {
                                _layers[idx] = _activeLayer!;
                              }
                            });
                          },
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Chọn hoặc thêm một lớp chữ để bắt đầu chỉnh sửa.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Section: Logo upload
                      Text(
                        'TẢI LÊN LOGO CỦA BẠN',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _uploadLogo,
                        child: Container(
                          height: 98,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.primary.withValues(alpha: 0.02),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                'NHẤN ĐỂ TẢI ẢNH LÊN',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PNG, JPG, SVG (Tối đa 5MB)',
                                style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Active design layers
                      Text(
                        'LỚP THIẾT KẾ HOẠT ĐỘNG',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_layers.isEmpty)
                        Text(
                          'Chưa có lớp thiết kế nào được tạo.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _layers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final layer = _layers[index];
                            final bool isActive = _activeLayer?.id == layer.id;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeLayer = layer;
                                  if (layer.type == LayerType.text) {
                                    _textController.text = layer.text;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFFF3F3F8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isActive ? AppColors.primary : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      layer.type == LayerType.text ? Icons.text_fields_rounded : Icons.image_rounded,
                                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            layer.type == LayerType.text ? layer.text : 'Logo của bạn',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            layer.type == LayerType.text
                                                ? '${layer.font} | ${layer.fontSize.toInt()}px'
                                                : 'Ảnh Tải Lên',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _layers.removeAt(index);
                                          if (_activeLayer?.id == layer.id) {
                                            _activeLayer = null;
                                            _textController.clear();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Bottom Pricing & Actions Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3)),
                ],
                border: Border(top: BorderSide(color: const Color(0xFFC1C6D7).withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TỔNG CỘNG SẢN PHẨM',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} ₫',
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Giá in thêm: ${_totalPrintingPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} ₫',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '(Gồm phôi & lớp in)',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reset Button
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFC1C6D7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _handleReset,
                      child: Text(
                        'Đặt lại',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Confirm Button
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _handleConfirm,
                      child: Text(
                        'Xác nhận',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
        if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang lưu thiết kế lên server...',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMaterialCard({
    required String title,
    required String priceAdd,
    required String desc,
  }) {
    final bool isSelected = _printMethod == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _printMethod = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.02) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFC1C6D7).withValues(alpha: 0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  width: isSelected ? 5.0 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        priceAdd,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
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
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 24),
      ),
      title: Column(
        children: [
          Transform(
            transform: Matrix4.skewX(-0.12),
            child: Text(
              'TÙY CHỈNH THIẾT KẾ',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.productName,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
