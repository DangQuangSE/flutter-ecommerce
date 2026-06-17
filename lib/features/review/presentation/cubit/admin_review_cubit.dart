import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/review/domain/repositories/review_repository.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/admin_review_state.dart';

/// Admin review management — view all reviews (paginated) and reply.
/// There is no hide/delete here by design: admins must not be able to
/// suppress genuine, if negative, customer feedback.
class AdminReviewCubit extends Cubit<AdminReviewState> {
  final ReviewRepository _repository;

  AdminReviewCubit(this._repository) : super(const AdminReviewInitial());

  static const int pageSize = 10;

  int _page = 0;

  Future<void> load({int page = 0}) async {
    _page = page;
    emit(const AdminReviewLoading());
    final result = await _repository.getAllReviews(page: _page, size: pageSize);
    switch (result) {
      case Success(:final data):
        emit(
          data.items.isEmpty
              ? const AdminReviewEmpty()
              : AdminReviewLoaded(
                  reviews: data.items,
                  page: data.page,
                  totalPages: data.totalPages,
                  totalElements: data.totalElements,
                  isLast: data.isLast,
                ),
        );
      case ResultFailure(:final failure):
        emit(AdminReviewError(failure.message));
    }
  }

  Future<void> refresh() => load(page: _page);

  /// Replies to a review. Returns `null` on success, or an error message.
  Future<String?> reply(int reviewId, String replyText) async {
    final current = state;
    if (current is AdminReviewLoaded) {
      emit(current.copyWith(isMutating: true));
    }
    final result = await _repository.replyToReview(reviewId, replyText);
    switch (result) {
      case Success():
        await refresh();
        return null;
      case ResultFailure(:final failure):
        if (current is AdminReviewLoaded) {
          emit(current.copyWith(isMutating: false));
        }
        return failure.message;
    }
  }
}
