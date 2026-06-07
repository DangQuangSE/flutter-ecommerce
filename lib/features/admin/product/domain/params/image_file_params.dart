import 'package:equatable/equatable.dart';

class ImageFileParams extends Equatable {
  final String path;
  final String name;

  const ImageFileParams({required this.path, required this.name});

  @override
  List<Object?> get props => [path, name];
}
