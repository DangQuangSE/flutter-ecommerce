import 'dart:typed_data';

abstract interface class CustomDesignRemoteDataSource {
  Future<int> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required Uint8List imageBytes,
  });
}
