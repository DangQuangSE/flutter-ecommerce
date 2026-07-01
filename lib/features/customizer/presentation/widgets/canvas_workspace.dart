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
                    AnimatedRotation(
                      turns: isFrontView ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAg16llodl6Hl8MPqH6DvSysphHsH9azINDafCIQFp9rqCHyIEj5IyNuBfAVIK7-s1m70zLJYYuRDn7ps4e9BkxeY1wfIJ58BidKV1GgULrOntZ7svsuNpwj8nvPhazvHISS-5OqI81qGvWmbwLlQlDr7PaeNVO1DpmYgljTca2s33rrrPqLBq7MLlaEkQdj7fqz_fN5K-XrOluv8Ux-V0w9V8-aE1C5t5BlJtTl7b0-7Tot4btl19oWsO5WWVz6wdqu1TcpvcIJ6k',
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
                      layers: layers,
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
