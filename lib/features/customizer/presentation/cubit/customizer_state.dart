import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/customization_entity.dart';

sealed class CustomizerState extends Equatable {
  const CustomizerState();

  @override
  List<Object?> get props => [];
}

final class CustomizerInitial extends CustomizerState {
  const CustomizerInitial();
}

final class CustomizerActive extends CustomizerState {
  final Map<String, CustomizationEntity> customizations;

  const CustomizerActive(this.customizations);

  @override
  List<Object?> get props => [customizations];
}
