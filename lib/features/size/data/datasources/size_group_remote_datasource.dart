import 'package:flutter_ecommerce/features/size/data/models/size_group_model.dart';

abstract interface class SizeGroupRemoteDatasource {
  Future<List<SizeGroupModel>> getSizeGroups();
  Future<SizeGroupModel> createSizeGroup(SizeGroupModel model);
  Future<SizeGroupModel> updateSizeGroup(int id, SizeGroupModel model);
  Future<void> deleteSizeGroup(int id);
}
