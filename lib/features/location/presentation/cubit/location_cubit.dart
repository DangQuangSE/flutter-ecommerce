import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/location/data/models/location_model.dart';
import 'package:flutter_ecommerce/features/location/domain/repositories/location_repository.dart';
import 'package:flutter_ecommerce/features/location/presentation/cubit/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository _repository;

  LocationCubit(this._repository) : super(const LocationInitial());

  Future<void> loadProvinces({String? initialProvinceName}) async {
    emit(const LocationLoading());
    final result = await _repository.getProvinces();
    switch (result) {
      case Success(:final data):
        LocationModel? selected;
        if (initialProvinceName != null) {
          try {
            selected = data.firstWhere(
              (p) => p.name.toLowerCase().trim() ==
                  initialProvinceName.toLowerCase().trim(),
            );
          } catch (_) {}
        }
        emit(LocationLoaded(
          provinces: data,
          selectedProvince: selected,
        ));
      case ResultFailure(:final failure):
        emit(LocationError(failure.message));
    }
  }

  Future<void> selectProvince(LocationModel province) async {
    final current = state;
    if (current is! LocationLoaded) return;
    emit(current.copyWith(
      selectedProvince: () => province,
      selectedDistrict: () => null,
      selectedWard: () => null,
      districts: [],
      wards: [],
      isLoadingDistricts: true,
    ));
    _loadDistricts(province.code);
  }

  Future<void> selectDistrict(LocationModel district) async {
    final current = state;
    if (current is! LocationLoaded) return;
    emit(current.copyWith(
      selectedDistrict: () => district,
      selectedWard: () => null,
      wards: [],
      isLoadingWards: true,
    ));
    _loadWards(district.code);
  }

  void selectWard(LocationModel ward) {
    final current = state;
    if (current is! LocationLoaded) return;
    emit(current.copyWith(selectedWard: () => ward));
  }

  Future<void> initializeFromNames(
      String? provinceName, String? districtName, String? wardName) async {
    // Step 1: load provinces
    emit(const LocationLoading());
    final provResult = await _repository.getProvinces();
    final List<LocationModel> provinces;
    switch (provResult) {
      case Success(:final data):
        provinces = data;
      case ResultFailure(:final failure):
        emit(LocationError(failure.message));
        return;
    }

    LocationModel? selectedProvince;
    if (provinceName != null) {
      try {
        selectedProvince = provinces.firstWhere(
          (p) => p.name.toLowerCase().trim() == provinceName.toLowerCase().trim(),
        );
      } catch (_) {}
    }
    emit(LocationLoaded(provinces: provinces, selectedProvince: selectedProvince));
    if (selectedProvince == null) return;

    // Step 2: load districts
    final distResult = await _repository.getDistricts(selectedProvince.code);
    final List<LocationModel> districts;
    switch (distResult) {
      case Success(:final data):
        districts = data;
      case ResultFailure():
        return;
    }

    LocationModel? selectedDistrict;
    if (districtName != null) {
      try {
        selectedDistrict = districts.firstWhere(
          (d) => d.name.toLowerCase().trim() == districtName.toLowerCase().trim(),
        );
      } catch (_) {}
    }

    final s1 = state;
    if (s1 is! LocationLoaded) return;
    emit(s1.copyWith(
      districts: districts,
      selectedDistrict: () => selectedDistrict,
      isLoadingDistricts: false,
    ));
    if (selectedDistrict == null) return;

    // Step 3: load wards
    final wardResult = await _repository.getWards(selectedDistrict.code);
    final List<LocationModel> wards;
    switch (wardResult) {
      case Success(:final data):
        wards = data;
      case ResultFailure():
        return;
    }

    LocationModel? selectedWard;
    if (wardName != null) {
      try {
        selectedWard = wards.firstWhere(
          (w) => w.name.toLowerCase().trim() == wardName.toLowerCase().trim(),
        );
      } catch (_) {}
    }

    final s2 = state;
    if (s2 is! LocationLoaded) return;
    emit(s2.copyWith(
      wards: wards,
      selectedWard: () => selectedWard,
      isLoadingWards: false,
    ));
  }

  Future<void> _loadDistricts(int provinceCode,
      {String? initialDistrictName}) async {
    final result = await _repository.getDistricts(provinceCode);
    switch (result) {
      case Success(:final data):
        final current = state;
        if (current is! LocationLoaded) return;

        LocationModel? selected;
        if (initialDistrictName != null) {
          try {
            selected = data.firstWhere(
              (d) => d.name.toLowerCase().trim() ==
                  initialDistrictName.toLowerCase().trim(),
            );
          } catch (_) {}
        }

        emit(current.copyWith(
          districts: data,
          isLoadingDistricts: false,
          selectedDistrict: () => selected,
        ));

        if (selected != null) {
          _loadWards(selected.code, initialWardName: null);
        }
      case ResultFailure():
        final current = state;
        if (current is LocationLoaded) {
          emit(current.copyWith(isLoadingDistricts: false));
        }
    }
  }

  Future<void> _loadWards(int districtCode,
      {String? initialWardName}) async {
    final result = await _repository.getWards(districtCode);
    switch (result) {
      case Success(:final data):
        final current = state;
        if (current is! LocationLoaded) return;

        LocationModel? selected;
        if (initialWardName != null) {
          try {
            selected = data.firstWhere(
              (w) => w.name.toLowerCase().trim() ==
                  initialWardName.toLowerCase().trim(),
            );
          } catch (_) {}
        }

        emit(current.copyWith(
          wards: data,
          isLoadingWards: false,
          selectedWard: () => selected,
        ));
      case ResultFailure():
        final current = state;
        if (current is LocationLoaded) {
          emit(current.copyWith(isLoadingWards: false));
        }
    }
  }
}
