import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/custom_design_spec_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_custom_design_spec_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_state.dart';

class CustomDesignSpecCubit extends Cubit<CustomDesignSpecState> {
  final GetCustomDesignSpecUseCase _getCustomDesignSpec;

  CustomDesignSpecCubit({
    required GetCustomDesignSpecUseCase getCustomDesignSpec,
  })  : _getCustomDesignSpec = getCustomDesignSpec,
        super(const CustomDesignSpecSnapshot());

  Future<void> loadSpec(int customDesignId) async {
    final current = _snapshot;
    if (current.specs.containsKey(customDesignId) ||
        current.loadingIds.contains(customDesignId)) {
      return;
    }

    emit(
      current.copyWith(
        loadingIds: {...current.loadingIds, customDesignId},
        errors: {...current.errors}..remove(customDesignId),
      ),
    );

    final result = await _getCustomDesignSpec(customDesignId);
    if (isClosed) return;

    final latest = _snapshot;
    final loadingIds = {...latest.loadingIds}..remove(customDesignId);

    switch (result) {
      case Success<CustomDesignSpecEntity>(:final data):
        emit(
          latest.copyWith(
            specs: {...latest.specs, customDesignId: data},
            loadingIds: loadingIds,
          ),
        );
      case ResultFailure<CustomDesignSpecEntity>(:final failure):
        emit(
          latest.copyWith(
            loadingIds: loadingIds,
            errors: {...latest.errors, customDesignId: failure.message},
          ),
        );
    }
  }

  CustomDesignSpecSnapshot get _snapshot {
    final current = state;
    return current is CustomDesignSpecSnapshot
        ? current
        : const CustomDesignSpecSnapshot();
  }
}
