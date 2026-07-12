import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';

class LayerOverlayStack extends StatelessWidget {
  final List<DesignLayer> layers;
  final String? activeLayerId;
  final double canvasWidth;
  final double canvasHeight;
  final ValueChanged<DesignLayer> onLayerActivated;
  final void Function(String id, Offset delta) onLayerDragged;
  final ValueChanged<String> onLayerDeleted;
  final TextStyle Function(String font) getFontFamily;

  const LayerOverlayStack({
    super.key,
    required this.layers,
    required this.activeLayerId,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.onLayerActivated,
    required this.onLayerDragged,
    required this.onLayerDeleted,
    required this.getFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: layers.map((layer) => _buildLayerItem(layer)).toList(),
    );
  }

  Widget _buildLayerItem(DesignLayer layer) {
    final bool isActive = activeLayerId == layer.id;
    return Positioned(
      left: (canvasWidth / 2) + layer.x,
      top: (canvasHeight / 2) + layer.y,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Listener(
              onPointerDown: (_) => onLayerActivated(layer),
              child: GestureDetector(
                onPanStart: (_) => onLayerActivated(layer),
                onPanUpdate: (details) =>
                    onLayerDragged(layer.id, details.delta),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 1.5,
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
                            style: getFontFamily(layer.font).copyWith(
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
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.antiAlias,
                          child: layer.hasRemoteLogo
                              ? CachedNetworkImage(
                                  imageUrl: layer.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, error, stackTrace) =>
                                      const Icon(Icons.sports_soccer_rounded,
                                          size: 28),
                                )
                              : layer.logoPath != null
                                  ? (kIsWeb
                                      ? Image.network(
                                          layer.logoPath!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(
                                                  Icons.sports_soccer_rounded,
                                                  size: 28),
                                        )
                                      : Image.file(
                                          File(layer.logoPath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(
                                                  Icons.sports_soccer_rounded,
                                                  size: 28),
                                        ))
                                  : const Icon(Icons.sports_soccer_rounded,
                                      size: 28),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (isActive) _buildDeleteHandle(layer.id),
            if (isActive) _buildResizeHandle(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteHandle(String layerId) => Positioned(
        top: -16,
        right: -16,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onLayerDeleted(layerId),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: const Icon(Icons.close_rounded,
                size: 12, color: AppColors.error),
          ),
        ),
      );

  Widget _buildResizeHandle() => Positioned(
        bottom: -16,
        right: -16,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.open_in_full_rounded,
              size: 10, color: Colors.white),
        ),
      );
}
