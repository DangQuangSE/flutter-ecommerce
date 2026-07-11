import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';

sealed class DesignViewerState { const DesignViewerState(); }
final class DesignViewerInitial extends DesignViewerState { const DesignViewerInitial(); }
final class DesignViewerLoading extends DesignViewerState { const DesignViewerLoading(); }
final class DesignViewerFailure extends DesignViewerState {
  final String message;
  const DesignViewerFailure(this.message);
}
final class DesignViewerLoaded extends DesignViewerState {
  final ExistingDesignEntity design;
  final LayerView side;
  final List<DesignLayer> frontLayers;
  final List<DesignLayer> backLayers;
  final bool frontWarning;
  final bool backWarning;
  final String? selectedLayerId;
  const DesignViewerLoaded({required this.design, required this.side, required this.frontLayers, required this.backLayers, required this.frontWarning, required this.backWarning, this.selectedLayerId});
  List<DesignLayer> get visibleLayers => side == LayerView.front ? frontLayers : backLayers;
  DesignLayer? get selectedLayer {
    for (final layer in visibleLayers) {
      if (layer.id == selectedLayerId) return layer;
    }
    return null;
  }
  DesignViewerLoaded copyWith({LayerView? side, String? selectedLayerId}) => DesignViewerLoaded(design: design, side: side ?? this.side, frontLayers: frontLayers, backLayers: backLayers, frontWarning: frontWarning, backWarning: backWarning, selectedLayerId: selectedLayerId);
}
