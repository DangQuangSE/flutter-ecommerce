import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/location/domain/entities/location_entity.dart';

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final List<LocationEntity> provinces;
  final List<LocationEntity> districts;
  final List<LocationEntity> wards;
  final LocationEntity? selectedProvince;
  final LocationEntity? selectedDistrict;
  final LocationEntity? selectedWard;
  final bool isLoadingDistricts;
  final bool isLoadingWards;

  const LocationLoaded({
    required this.provinces,
    this.districts = const [],
    this.wards = const [],
    this.selectedProvince,
    this.selectedDistrict,
    this.selectedWard,
    this.isLoadingDistricts = false,
    this.isLoadingWards = false,
  });

  LocationLoaded copyWith({
    List<LocationEntity>? provinces,
    List<LocationEntity>? districts,
    List<LocationEntity>? wards,
    LocationEntity? Function()? selectedProvince,
    LocationEntity? Function()? selectedDistrict,
    LocationEntity? Function()? selectedWard,
    bool? isLoadingDistricts,
    bool? isLoadingWards,
  }) {
    return LocationLoaded(
      provinces: provinces ?? this.provinces,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
      selectedProvince:
          selectedProvince != null ? selectedProvince() : this.selectedProvince,
      selectedDistrict:
          selectedDistrict != null ? selectedDistrict() : this.selectedDistrict,
      selectedWard: selectedWard != null ? selectedWard() : this.selectedWard,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts,
      isLoadingWards: isLoadingWards ?? this.isLoadingWards,
    );
  }

  @override
  List<Object?> get props => [
        provinces,
        districts,
        wards,
        selectedProvince,
        selectedDistrict,
        selectedWard,
        isLoadingDistricts,
        isLoadingWards,
      ];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
