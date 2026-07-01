import 'package:flutter_ecommerce/features/customizer/domain/entities/custom_design_spec_entity.dart';

sealed class CustomDesignSpecState {
  const CustomDesignSpecState();
}

final class CustomDesignSpecSnapshot extends CustomDesignSpecState {
  final Map<int, CustomDesignSpecEntity> specs;
  final Set<int> loadingIds;
  final Map<int, String> errors;

  const CustomDesignSpecSnapshot({
    this.specs = const {},
    this.loadingIds = const {},
    this.errors = const {},
  });

  bool isLoading(int customDesignId) => loadingIds.contains(customDesignId);

  CustomDesignSpecEntity? specOf(int customDesignId) => specs[customDesignId];

  String? errorOf(int customDesignId) => errors[customDesignId];

  CustomDesignSpecSnapshot copyWith({
    Map<int, CustomDesignSpecEntity>? specs,
    Set<int>? loadingIds,
    Map<int, String>? errors,
  }) {
    return CustomDesignSpecSnapshot(
      specs: specs ?? this.specs,
      loadingIds: loadingIds ?? this.loadingIds,
      errors: errors ?? this.errors,
    );
  }
}
