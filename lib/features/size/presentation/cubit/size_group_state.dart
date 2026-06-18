import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';

sealed class SizeGroupState extends Equatable {
  const SizeGroupState();

  @override
  List<Object?> get props => [];
}

class SizeGroupInitial extends SizeGroupState {
  const SizeGroupInitial();
}

class SizeGroupLoading extends SizeGroupState {
  const SizeGroupLoading();
}

class SizeGroupSuccess extends SizeGroupState {
  final List<SizeGroupEntity> groups;
  final String? message;
  final bool isSubmitting;

  const SizeGroupSuccess({
    required this.groups,
    this.message,
    this.isSubmitting = false,
  });

  SizeGroupSuccess copyWith({
    List<SizeGroupEntity>? groups,
    String? message,
    bool? isSubmitting,
  }) {
    return SizeGroupSuccess(
      groups: groups ?? this.groups,
      message: message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [groups, message, isSubmitting];
}

class SizeGroupError extends SizeGroupState {
  final String message;

  const SizeGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class SizeGroupEmpty extends SizeGroupState {
  const SizeGroupEmpty();
}
