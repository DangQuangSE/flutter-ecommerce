import 'package:equatable/equatable.dart';

class ProductImageEntity extends Equatable {
  final int id;
  final String imageUrl;
  final bool isThumbnail;
  final int sortOrder;

  const ProductImageEntity({
    required this.id,
    required this.imageUrl,
    required this.isThumbnail,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, imageUrl, isThumbnail, sortOrder];
}
