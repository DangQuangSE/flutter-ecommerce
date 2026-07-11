import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

class GetDesignForViewerUseCase {
  final CustomDesignRepository _repository;

  const GetDesignForViewerUseCase(this._repository);

  Future<Result<ExistingDesignEntity>> call(
    int id, {
    required DesignViewerRole role,
  }) => _repository.getDesignForViewer(id, role: role);
}
