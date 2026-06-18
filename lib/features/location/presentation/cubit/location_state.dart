import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/location/data/models/location_model.dart';

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
  final List<LocationModel> provinces;
  final List<LocationModel> districts;
  final List<LocationModel> wards;
  final LocationModel? selectedProvince;
  final LocationModel? selectedDistrict;
  final LocationModel? selectedWard;
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
    List<LocationModel>? provinces,
    List<LocationModel>? districts,
    List<LocationModel>? wards,
    LocationModel? Function()? selectedProvince,
    LocationModel? Function()? selectedDistrict,
    LocationModel? Function()? selectedWard,
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
      selectedWard:
          selectedWard != null ? selectedWard() : this.selectedWard,
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
