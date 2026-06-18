import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/review/domain/entities/review_entity.dart';

/// A page of reviews from the paginated admin list endpoint
/// (`GET /api/admin/reviews`).
class ReviewPage extends Equatable {
  final List<ReviewEntity> items;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const ReviewPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  @override
  List<Object?> get props => [items, page, totalPages, totalElements, isLast];
}
