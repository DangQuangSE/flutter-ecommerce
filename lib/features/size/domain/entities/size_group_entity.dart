import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_option_entity.dart';

class SizeGroupEntity extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final List<SizeOptionEntity> sizes;

  const SizeGroupEntity({
    this.id,
    required this.name,
    this.description,
    this.sizes = const [],
  });

  SizeGroupEntity copyWith({
    int? id,
    String? name,
    String? description,
    List<SizeOptionEntity>? sizes,
  }) {
    return SizeGroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sizes: sizes ?? this.sizes,
    );
  }

  @override
  List<Object?> get props => [id, name, description, sizes];
}
