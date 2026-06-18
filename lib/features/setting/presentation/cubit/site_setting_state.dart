import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/setting/domain/entities/site_setting_entity.dart';

sealed class SiteSettingState extends Equatable {
  const SiteSettingState();

  @override
  List<Object?> get props => [];
}

class SiteSettingInitial extends SiteSettingState {
  const SiteSettingInitial();
}

class SiteSettingLoading extends SiteSettingState {
  const SiteSettingLoading();
}

class SiteSettingLoaded extends SiteSettingState {
  final SiteSettingEntity settings;
  final String? message;
  final bool isSubmitting;

  const SiteSettingLoaded({
    required this.settings,
    this.message,
    this.isSubmitting = false,
  });

  SiteSettingLoaded copyWith({
    SiteSettingEntity? settings,
    String? message,
    bool? isSubmitting,
  }) {
    return SiteSettingLoaded(
      settings: settings ?? this.settings,
      message: message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [settings, message, isSubmitting];
}

class SiteSettingError extends SiteSettingState {
  final String message;

  const SiteSettingError(this.message);

  @override
  List<Object?> get props => [message];
}
