part of 'customizer_page.dart';

extension _CustomizerActions on _CustomizerPageState {
  void _addNewTextLayer() {
    _updateState(() {
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
        _updateState(() {
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
    _updateState(() {
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
              _updateState(() {
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
    _updateState(() => _activeLayer = null);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _captureCanvas();
    _updateState(() => _activeLayer = previousActive);
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
}
