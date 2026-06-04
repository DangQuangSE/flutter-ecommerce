import 'package:equatable/equatable.dart';

class PrintingColorEntity extends Equatable {
  final int? id;
  final String name;
  final String hexCode;
  final bool isActive;

  const PrintingColorEntity({
    this.id,
    required this.name,
    required this.hexCode,
    required this.isActive,
  });

  PrintingColorEntity copyWith({
    int? id,
    String? name,
    String? hexCode,
    bool? isActive,
  }) {
    return PrintingColorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      hexCode: hexCode ?? this.hexCode,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, hexCode, isActive];
}
