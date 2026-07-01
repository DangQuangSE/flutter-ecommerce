import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/widgets/layer_overlay_stack.dart';

class CanvasWorkspace extends StatelessWidget {
  final GlobalKey canvasKey;
  final List<DesignLayer> layers;
  final String? activeLayerId;
  final bool isFrontView;
  final double zoomScale;
  final double rotationAngle;
  final ValueChanged<bool> onFrontViewChanged;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<DesignLayer> onLayerActivated;
  final void Function(String id, Offset delta) onLayerDragged;
  final ValueChanged<String> onLayerDeleted;
  final TextStyle Function(String font) getFontFamily;

  const CanvasWorkspace({
    super.key,
    required this.canvasKey,
    required this.layers,
    required this.activeLayerId,
    required this.isFrontView,
    required this.zoomScale,
    required this.rotationAngle,
    required this.onFrontViewChanged,
    required this.onZoomChanged,
    required this.onLayerActivated,
    required this.onLayerDragged,
    required this.onLayerDeleted,
    required this.getFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final canvasWidth =
        MediaQuery.of(context).size.width * AppSizes.canvasWidthRatio;
    final canvasHeight =
        MediaQuery.of(context).size.height * AppSizes.canvasHeightRatio;
    final currentView = isFrontView ? LayerView.front : LayerView.back;
    final visibleLayers = layers.where((l) => l.view == currentView).toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: [
                AppColors.canvasGradientStart,
                AppColors.canvasGradientEnd
              ],
            ),
          ),
        ),
        Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(zoomScale, zoomScale, 1.0)
              ..rotateZ(rotationAngle),
            child: RepaintBoundary(
              key: canvasKey,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: CachedNetworkImage(
                        key: ValueKey(isFrontView ? 'front' : 'back'),
                        imageUrl: isFrontView
                            ? 'https://res.cloudinary.com/dq8qlmvhn/image/upload/v1782924800/tshirt-customizer/front-view.png'
                            : 'https://res.cloudinary.com/dq8qlmvhn/image/upload/v1782924804/tshirt-customizer/back-view.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (!isFrontView)
                      Positioned(
                        top: AppSizes.paddingMd - 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: AppSizes.paddingXs),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusLg),
                          ),
                          child: Text(
                            'MẶT SAU (BACK VIEW)',
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    LayerOverlayStack(
                      layers: visibleLayers,
                      activeLayerId: activeLayerId,
                      canvasWidth: canvasWidth,
                      canvasHeight: canvasHeight,
                      onLayerActivated: onLayerActivated,
                      onLayerDragged: onLayerDragged,
                      onLayerDeleted: onLayerDeleted,
                      getFontFamily: getFontFamily,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildZoomPanel(),
        _buildFrontBackSwitch(),
      ],
    );
  }

  Widget _buildZoomPanel() {
    return Positioned(
      top: AppSizes.paddingMd,
      right: AppSizes.paddingMd,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            IconButton(
              icon: Icon(Icons.zoom_in_rounded),
              color: AppColors.textPrimary,
              onPressed: () {
                if (zoomScale < AppSizes.canvasMaxZoom) {
                  onZoomChanged(zoomScale + AppSizes.canvasZoomStep);
                }
              },
            ),
            Container(width: 20, height: 1, color: AppColors.selectedBg),
            IconButton(
              icon: Icon(Icons.zoom_out_rounded),
              color: AppColors.textPrimary,
              onPressed: () {
                if (zoomScale > AppSizes.canvasMinZoom) {
                  onZoomChanged(zoomScale - AppSizes.canvasZoomStep);
                }
              },
            ),
            Container(width: 20, height: 1, color: AppColors.selectedBg),
            IconButton(
              icon: Icon(Icons.restart_alt_rounded),
              color: AppColors.textPrimary,
              onPressed: () => onZoomChanged(1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontBackSwitch() {
    return Positioned(
      bottom: AppSizes.paddingMd,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingXs),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewButton(
                  'MẶT TRƯỚC', isFrontView, () => onFrontViewChanged(true)),
              SizedBox(width: AppSizes.paddingXs),
              _buildViewButton(
                  'MẶT SAU', !isFrontView, () => onFrontViewChanged(false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: AppSizes.paddingSm - 2),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontXs + 1,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
