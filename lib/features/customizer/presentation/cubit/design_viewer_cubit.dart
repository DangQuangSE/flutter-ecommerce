import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_design_for_viewer_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/design_viewer_state.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_metadata_parser.dart';

class DesignViewerCubit extends Cubit<DesignViewerState> {
  final GetDesignForViewerUseCase _getDesign;
  DesignViewerCubit(this._getDesign) : super(const DesignViewerInitial());
  Future<void> load(int id, DesignViewerRole role) async {
    emit(const DesignViewerLoading());
    final result = await _getDesign(id, role: role);
    switch (result) {
      case Success<ExistingDesignEntity>(:final data):
        final front = DesignMetadataParser.parse(data.designMetadata);
        final back = DesignMetadataParser.parse(data.backDesignMetadata);
        final backLayers = back.layers
            .map((layer) => layer.copyWith(view: LayerView.back))
            .toList();
        final initialSide = data.designImageUrl?.isNotEmpty == true
            ? LayerView.front
            : LayerView.back;
        emit(DesignViewerLoaded(design: data, side: initialSide, frontLayers: front.layers, backLayers: backLayers, frontWarning: front.hasWarning, backWarning: back.hasWarning));
      case ResultFailure<ExistingDesignEntity>(:final failure):
        emit(DesignViewerFailure(failure.message));
    }
  }
  void selectSide(LayerView side) { final current = state; if (current is DesignViewerLoaded) emit(current.copyWith(side: side)); }
  void selectLayer(String id) { final current = state; if (current is DesignViewerLoaded) emit(current.copyWith(selectedLayerId: id)); }
}
