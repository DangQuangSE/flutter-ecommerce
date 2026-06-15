import 'package:equatable/equatable.dart';

class SizeOptionEntity extends Equatable {
  final int? id;
  final String name;
  final int displayOrder;

  const SizeOptionEntity({
    this.id,
    required this.name,
    required this.displayOrder,
  });

  SizeOptionEntity copyWith({int? id, String? name, int? displayOrder}) {
    return SizeOptionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  List<Object?> get props => [id, name, displayOrder];
}
