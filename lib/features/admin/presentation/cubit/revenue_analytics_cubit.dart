import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/revenue_analytics_entity.dart';
import '../../domain/usecases/get_revenue_analytics_usecase.dart';
import 'revenue_analytics_state.dart';

class RevenueAnalyticsCubit extends Cubit<RevenueAnalyticsState> {
  final GetRevenueAnalyticsUseCase _getRevenue;
  int _token = 0;
  DateTime? _start, _end;
  RevenueAnalyticsCubit(this._getRevenue) : super(const RevenueAnalyticsInitial());
  Future<void> loadDefault() { final today=DateTime.now(); return load(today.subtract(const Duration(days: 6)), today); }
  Future<void> load(DateTime start, DateTime end) async {
    if (start.isAfter(end) || end.difference(start).inDays >= 366 * 5) { emit(const RevenueAnalyticsError('Khoảng ngày không hợp lệ', null)); return; }
    _start=start; _end=end; final token=++_token; final previous=_current; emit(RevenueAnalyticsLoading(previous));
    final result=await _getRevenue(start,end); if (token != _token || isClosed) return;
    switch(result) { case Success<RevenueAnalyticsEntity>(:final data): emit(RevenueAnalyticsLoaded(data)); case ResultFailure<RevenueAnalyticsEntity>(:final failure): emit(RevenueAnalyticsError(failure.message, previous)); }
  }
  Future<void> refresh() => _start == null ? loadDefault() : load(_start!, _end!);
  RevenueAnalyticsEntity? get _current => switch(state) { RevenueAnalyticsLoaded(:final data)=>data, RevenueAnalyticsLoading(:final previous)=>previous, RevenueAnalyticsError(:final previous)=>previous, _=>null };
}
