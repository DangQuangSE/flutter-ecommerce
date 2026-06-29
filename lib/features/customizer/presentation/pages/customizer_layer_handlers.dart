part of 'customizer_page.dart';

extension _CustomizerLayerHandlers on _CustomizerPageState {
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

  void _onFrontViewChanged(bool v) => _updateState(() => _isFrontView = v);
  void _onZoomChanged(double v) => _updateState(() => _zoomScale = v);
  void _onPrintMethodChanged(String v) => _updateState(() => _printMethod = v);

  void _onLayerActivatedFromCanvas(DesignLayer layer) => _updateState(() {
        _activeLayer = layer;
        if (layer.type == LayerType.text) {
          _textController.text = layer.text;
          _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length));
        }
      });

  void _onLayerDragged(String id, Offset delta) => _updateState(() {
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

  void _onLayerDeletedFromCanvas(String id) => _updateState(() {
        _layers.removeWhere((l) => l.id == id);
        _activeLayer = null;
        _textController.clear();
      });

  void _onActiveLayerPropChanged(DesignLayer Function(DesignLayer) updater) =>
      _updateState(() {
        if (_activeLayer == null) return;
        _activeLayer = updater(_activeLayer!);
        final idx = _layers.indexWhere((l) => l.id == _activeLayer!.id);
        if (idx != -1) _layers[idx] = _activeLayer!;
      });

  void _onPanelLayerActivated(DesignLayer layer) => _updateState(() {
        _activeLayer = layer;
        if (layer.type == LayerType.text) _textController.text = layer.text;
      });

  void _onPanelLayerDeleted(int index, String id) => _updateState(() {
        _layers.removeAt(index);
        if (_activeLayer?.id == id) {
          _activeLayer = null;
          _textController.clear();
        }
      });
}
