import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/setting/domain/repositories/site_setting_repository.dart';
import 'site_setting_state.dart';

class SiteSettingCubit extends Cubit<SiteSettingState> {
  final SiteSettingRepository _repository;

  SiteSettingCubit(this._repository) : super(const SiteSettingInitial());

  Future<void> loadSettings() async {
    emit(const SiteSettingLoading());
    final result = await _repository.getSettings();
    switch (result) {
      case Success(:final data):
        emit(SiteSettingLoaded(settings: data));
      case ResultFailure(:final failure):
        emit(SiteSettingError(failure.message));
    }
  }

  Future<void> updateReturnPolicy(String returnPolicy) async {
    final currentState = state;
    if (currentState is SiteSettingLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.updateSettings(returnPolicy);
      switch (result) {
        case Success(:final data):
          emit(SiteSettingLoaded(
            settings: data,
            message: 'Đã cập nhật chính sách đổi trả thành công!',
          ));
        case ResultFailure(:final failure):
          emit(currentState.copyWith(isSubmitting: false));
          emit(SiteSettingError(failure.message));
      }
    }
  }
}
