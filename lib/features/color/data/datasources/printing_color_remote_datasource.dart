import 'package:flutter_ecommerce/features/color/data/models/printing_color_model.dart';

abstract interface class PrintingColorRemoteDataSource {
  Future<List<PrintingColorModel>> getColors();
  Future<PrintingColorModel> createColor(PrintingColorModel color);
  Future<PrintingColorModel> updateColor(int id, PrintingColorModel color);
  Future<void> deleteColor(int id);
}
