import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';

sealed class WriteReviewState extends Equatable {
  const WriteReviewState();

  @override
  List<Object?> get props => [];
}

class WriteReviewInitial extends WriteReviewState {
  const WriteReviewInitial();
}

class WriteReviewSubmitting extends WriteReviewState {
  const WriteReviewSubmitting();
}

class WriteReviewSuccess extends WriteReviewState {
  final ReviewEntity review;
  const WriteReviewSuccess(this.review);

  @override
  List<Object?> get props => [review];
}

class WriteReviewError extends WriteReviewState {
  final String message;
  const WriteReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
