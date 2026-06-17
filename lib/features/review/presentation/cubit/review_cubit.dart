import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/review/domain/repositories/review_repository.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _repository;

  ReviewCubit(this._repository) : super(const ReviewInitial());

  Future<void> loadReviews(int productId) async {
    emit(const ReviewLoading());
    final result = await _repository.getProductReviews(productId);
    switch (result) {
      case Success(:final data):
        emit(data.isEmpty ? const ReviewEmpty() : ReviewLoaded(data));
      case ResultFailure(:final failure):
        emit(ReviewError(failure.message));
    }
  }
}
