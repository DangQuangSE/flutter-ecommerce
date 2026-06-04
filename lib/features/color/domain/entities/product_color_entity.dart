import 'package:equatable/equatable.dart';

class ProductColorEntity extends Equatable {
  final int? id;
  final String name;
  final String hexCode;

  const ProductColorEntity({
    this.id,
    required this.name,
    required this.hexCode,
  });

  ProductColorEntity copyWith({
    int? id,
    String? name,
    String? hexCode,
  }) {
    return ProductColorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      hexCode: hexCode ?? this.hexCode,
    );
  }

  @override
  List<Object?> get props => [id, name, hexCode];
}
