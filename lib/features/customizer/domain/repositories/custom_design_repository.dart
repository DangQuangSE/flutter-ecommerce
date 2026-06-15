import 'dart:typed_data';
import 'package:flutter_ecommerce/core/errors/result.dart';

abstract interface class CustomDesignRepository {
  Future<Result<int>> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required Uint8List imageBytes,
  });
}
