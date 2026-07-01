import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/create_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/delete_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/get_size_groups_usecase.dart';
import 'package:flutter_ecommerce/features/size/domain/usecases/update_size_group_usecase.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_state.dart';

class SizeGroupCubit extends Cubit<SizeGroupState> {
  final GetSizeGroupsUseCase _getUseCase;
  final CreateSizeGroupUseCase _createUseCase;
  final UpdateSizeGroupUseCase _updateUseCase;
  final DeleteSizeGroupUseCase _deleteUseCase;

  SizeGroupCubit({
    required GetSizeGroupsUseCase getSizeGroupsUseCase,
    required CreateSizeGroupUseCase createSizeGroupUseCase,
    required UpdateSizeGroupUseCase updateSizeGroupUseCase,
    required DeleteSizeGroupUseCase deleteSizeGroupUseCase,
  })  : _getUseCase = getSizeGroupsUseCase,
        _createUseCase = createSizeGroupUseCase,
        _updateUseCase = updateSizeGroupUseCase,
        _deleteUseCase = deleteSizeGroupUseCase,
        super(const SizeGroupInitial());

  Future<void> loadSizeGroups() async {
    emit(const SizeGroupLoading());
    final result = await _getUseCase();
    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(const SizeGroupEmpty());
        } else {
          emit(SizeGroupSuccess(groups: data));
        }
      case ResultFailure(:final failure):
        emit(SizeGroupError(failure.message));
    }
  }

  Future<void> createSizeGroup(SizeGroupEntity entity) async {
    final current = state;
    if (current is SizeGroupSuccess) {
      emit(current.copyWith(isSubmitting: true));
    }
    final result = await _createUseCase(entity);
    switch (result) {
      case Success(:final data):
        final groups = _currentGroups();
        emit(SizeGroupSuccess(
          groups: [data, ...groups],
          message: AppStrings.adminSizeGroupCreated,
        ));
      case ResultFailure(:final failure):
        emit(SizeGroupError(failure.message));
    }
  }

  Future<void> updateSizeGroup(int id, SizeGroupEntity entity) async {
    final current = state;
    if (current is SizeGroupSuccess) {
      emit(current.copyWith(isSubmitting: true));
    }
    final result = await _updateUseCase(id, entity);
    switch (result) {
      case Success(:final data):
        final updated = _currentGroups()
            .map((group) => group.id == id ? data : group)
            .toList();
        emit(SizeGroupSuccess(
          groups: updated,
          message: AppStrings.adminSizeGroupUpdated,
        ));
      case ResultFailure(:final failure):
        emit(SizeGroupError(failure.message));
    }
  }

  Future<void> deleteSizeGroup(int id) async {
    final current = state;
    if (current is SizeGroupSuccess) {
      emit(current.copyWith(isSubmitting: true));
    }
    final result = await _deleteUseCase(id);
    switch (result) {
      case Success():
        final remaining =
            _currentGroups().where((group) => group.id != id).toList();
        if (remaining.isEmpty) {
          emit(const SizeGroupEmpty());
        } else {
          emit(SizeGroupSuccess(
            groups: remaining,
            message: AppStrings.adminSizeGroupDeleted,
          ));
        }
      case ResultFailure(:final failure):
        emit(SizeGroupError(failure.message));
    }
  }

  List<SizeGroupEntity> _currentGroups() {
    final current = state;
    return current is SizeGroupSuccess ? current.groups : [];
  }
}
