import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';

class CategoryFormExtra {
  final CategoryCubit cubit;
  final CategoryEntity? category;
  final List<CategoryEntity> parents;

  const CategoryFormExtra({
    required this.cubit,
    required this.parents,
    this.category,
  });
}
