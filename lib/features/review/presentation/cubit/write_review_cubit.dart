import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/review/domain/repositories/review_repository.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/write_review_state.dart';

class WriteReviewCubit extends Cubit<WriteReviewState> {
  final ReviewRepository _repository;

  WriteReviewCubit(this._repository) : super(const WriteReviewInitial());

  Future<void> submit({
    required int orderItemId,
    required int rating,
    required String comment,
    List<String> imagePaths = const [],
  }) async {
    emit(const WriteReviewSubmitting());
    final result = await _repository.createReview(
      orderItemId: orderItemId,
      rating: rating,
      comment: comment,
      imagePaths: imagePaths,
    );
    switch (result) {
      case Success(:final data):
        emit(WriteReviewSuccess(data));
      case ResultFailure(:final failure):
        emit(WriteReviewError(failure.message));
    }
  }
}
