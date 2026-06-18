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
        if (selected != null) {
          _loadDistricts(selected.code, initialDistrictName: null);
        }
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
    await loadProvinces(initialProvinceName: provinceName);

    final current = state;
    if (current is! LocationLoaded || current.selectedProvince == null) return;

    if (districtName != null) {
      try {
        final district = current.districts.firstWhere(
          (d) => d.name.toLowerCase().trim() ==
              districtName.toLowerCase().trim(),
        );
        emit(current.copyWith(
          selectedDistrict: () => district,
          isLoadingWards: true,
        ));
        await _loadWards(district.code);

        if (wardName != null) {
          final updated = this.state;
          if (updated is LocationLoaded) {
            try {
              final ward = updated.wards.firstWhere(
                (w) => w.name.toLowerCase().trim() ==
                    wardName.toLowerCase().trim(),
              );
              emit(updated.copyWith(selectedWard: () => ward));
            } catch (_) {}
          }
        }
      } catch (_) {}
    }
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
