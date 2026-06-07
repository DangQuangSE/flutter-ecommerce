import 'package:equatable/equatable.dart';

/// A node in the category hierarchy returned by `GET /api/categories/tree`.
/// Each node may contain nested [children].
class CategoryTreeNode extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final int? displayOrder;
  final bool isCustomizable;
  final List<CategoryTreeNode> children;

  const CategoryTreeNode({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
    this.displayOrder,
    this.isCustomizable = false,
    this.children = const [],
  });

  @override
  List<Object?> get props =>
      [id, name, slug, imageUrl, displayOrder, isCustomizable, children];
}
