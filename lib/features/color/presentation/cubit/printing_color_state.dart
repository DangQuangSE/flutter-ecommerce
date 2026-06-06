import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/printing_color_entity.dart';

sealed class PrintingColorState extends Equatable {
  const PrintingColorState();

  @override
  List<Object?> get props => [];
}

class PrintingColorInitial extends PrintingColorState {
  const PrintingColorInitial();
}

class PrintingColorLoading extends PrintingColorState {
  const PrintingColorLoading();
}

class PrintingColorLoaded extends PrintingColorState {
  final List<PrintingColorEntity> colors;
  final String? message;
  final bool isSubmitting;

  const PrintingColorLoaded({
    required this.colors,
    this.message,
    this.isSubmitting = false,
  });

  PrintingColorLoaded copyWith({
    List<PrintingColorEntity>? colors,
    String? message,
    bool? isSubmitting,
  }) {
    return PrintingColorLoaded(
      colors: colors ?? this.colors,
      message: message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [colors, message, isSubmitting];
}

class PrintingColorError extends PrintingColorState {
  final String message;

  const PrintingColorError(this.message);

  @override
  List<Object?> get props => [message];
}
