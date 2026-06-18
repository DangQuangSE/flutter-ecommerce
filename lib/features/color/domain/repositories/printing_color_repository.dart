import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/printing_color_entity.dart';

abstract interface class PrintingColorRepository {
  Future<Result<List<PrintingColorEntity>>> getColors();
  Future<Result<PrintingColorEntity>> createColor(PrintingColorEntity color);
  Future<Result<PrintingColorEntity>> updateColor(
      int id, PrintingColorEntity color);
  Future<Result<void>> deleteColor(int id);
}
