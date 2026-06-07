import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/usecases/get_admin_product_detail_usecase.dart';

part 'admin_product_detail_state.dart';

class AdminProductDetailCubit extends Cubit<AdminProductDetailState> {
  final GetAdminProductDetailUseCase _getDetail;

  AdminProductDetailCubit(this._getDetail) : super(AdminProductDetailInitial());

  Future<void> loadDetail(int productId) async {
    emit(AdminProductDetailLoading());
    final result = await _getDetail(productId);
    switch (result) {
      case Success(:final data):
        emit(AdminProductDetailSuccess(data));
      case ResultFailure(:final failure):
        emit(AdminProductDetailFailure(failure.message));
    }
  }

  Future<void> refresh(int productId) => loadDetail(productId);
}
