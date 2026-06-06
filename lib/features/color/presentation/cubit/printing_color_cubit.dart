import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/printing_color_entity.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/printing_color_repository.dart';
import 'printing_color_state.dart';

class PrintingColorCubit extends Cubit<PrintingColorState> {
  final PrintingColorRepository _repository;

  PrintingColorCubit(this._repository) : super(const PrintingColorInitial());

  Future<void> loadColors() async {
    emit(const PrintingColorLoading());
    final result = await _repository.getColors();
    switch (result) {
      case Success(:final data):
        emit(PrintingColorLoaded(colors: data));
      case ResultFailure(:final failure):
        emit(PrintingColorError(failure.message));
    }
  }

  Future<void> createColor(PrintingColorEntity color) async {
    final currentState = state;
    if (currentState is PrintingColorLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.createColor(color);
      switch (result) {
        case Success(:final data):
          final updatedList = List<PrintingColorEntity>.from(currentState.colors)..insert(0, data);
          emit(PrintingColorLoaded(
            colors: updatedList,
            message: 'Đã thêm màu in ấn thành công!',
          ));
        case ResultFailure(:final failure):
          emit(PrintingColorError(failure.message));
      }
    }
  }

  Future<void> updateColor(int id, PrintingColorEntity color) async {
    final currentState = state;
    if (currentState is PrintingColorLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.updateColor(id, color);
      switch (result) {
        case Success(:final data):
          final updatedList = currentState.colors.map((c) => c.id == id ? data : c).toList();
          emit(PrintingColorLoaded(
            colors: updatedList,
            message: 'Đã cập nhật màu in ấn thành công!',
          ));
        case ResultFailure(:final failure):
          emit(PrintingColorError(failure.message));
      }
    }
  }

  Future<void> deleteColor(int id) async {
    final currentState = state;
    if (currentState is PrintingColorLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.deleteColor(id);
      switch (result) {
        case Success():
          final updatedList = currentState.colors.where((c) => c.id != id).toList();
          emit(PrintingColorLoaded(
            colors: updatedList,
            message: 'Đã xóa màu in ấn thành công!',
          ));
        case ResultFailure(:final failure):
          emit(PrintingColorError(failure.message));
      }
    }
  }

  Future<void> toggleColorStatus(int id, bool isActive) async {
    final currentState = state;
    if (currentState is PrintingColorLoaded) {
      final updatedColors = currentState.colors.map((c) {
        if (c.id == id) {
          return c.copyWith(isActive: isActive);
        }
        return c;
      }).toList();

      // Speculatively emit the updated active status for instant response
      emit(currentState.copyWith(colors: updatedColors));

      final colorToUpdate = currentState.colors.firstWhere((c) => c.id == id).copyWith(isActive: isActive);
      final result = await _repository.updateColor(id, colorToUpdate);
      switch (result) {
        case Success():
          emit(PrintingColorLoaded(
            colors: updatedColors,
            message: 'Đã cập nhật trạng thái màu in!',
          ));
        case ResultFailure(:final failure):
          // Rollback
          final rolledBackColors = currentState.colors.map((c) {
            if (c.id == id) {
              return c.copyWith(isActive: !isActive);
            }
            return c;
          }).toList();
          emit(PrintingColorLoaded(colors: rolledBackColors));
          emit(PrintingColorError(failure.message));
      }
    }
  }
}
