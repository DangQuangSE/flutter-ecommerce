import 'package:equatable/equatable.dart';

class SiteSettingEntity extends Equatable {
  final String returnPolicy;

  const SiteSettingEntity({required this.returnPolicy});

  @override
  List<Object?> get props => [returnPolicy];
}
