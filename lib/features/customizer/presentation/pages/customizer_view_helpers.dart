part of 'customizer_page.dart';

extension _CustomizerViewHelpers on _CustomizerPageState {
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
