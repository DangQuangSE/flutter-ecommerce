import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';

sealed class AdminReviewState extends Equatable {
  const AdminReviewState();

  @override
  List<Object?> get props => [];
}

final class AdminReviewInitial extends AdminReviewState {
  const AdminReviewInitial();
}

final class AdminReviewLoading extends AdminReviewState {
  const AdminReviewLoading();
}

final class AdminReviewLoaded extends AdminReviewState {
  final List<ReviewEntity> reviews;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  /// True while a reply round-trip is in flight, so the UI can show a
  /// subtle busy indicator without dropping the current list.
  final bool isMutating;

  const AdminReviewLoaded({
    required this.reviews,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
    this.isMutating = false,
  });

  AdminReviewLoaded copyWith({
    List<ReviewEntity>? reviews,
    int? page,
    int? totalPages,
    int? totalElements,
    bool? isLast,
    bool? isMutating,
  }) {
    return AdminReviewLoaded(
      reviews: reviews ?? this.reviews,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      isLast: isLast ?? this.isLast,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props =>
      [reviews, page, totalPages, totalElements, isLast, isMutating];
}

final class AdminReviewEmpty extends AdminReviewState {
  const AdminReviewEmpty();
}

final class AdminReviewError extends AdminReviewState {
  final String message;
  const AdminReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
