import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_cubit.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_state.dart';
import 'package:flutter_ecommerce/features/brand/presentation/widgets/brand_card.dart';
import 'package:flutter_ecommerce/features/brand/presentation/widgets/brand_delete_dialog.dart';
import 'package:flutter_ecommerce/features/brand/presentation/widgets/brand_form_sheet.dart';
import 'package:flutter_ecommerce/features/brand/presentation/widgets/brand_management_app_bar.dart';
import 'package:flutter_ecommerce/features/brand/presentation/widgets/brand_search_bar.dart';
import 'package:flutter_ecommerce/features/brand/presentation/widgets/brand_state_views.dart';

class BrandManagementPage extends StatefulWidget {
  const BrandManagementPage({super.key});

  @override
  State<BrandManagementPage> createState() => _BrandManagementPageState();
}

class _BrandManagementPageState extends State<BrandManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  BrandCubit get _cubit => context.read<BrandCubit>();

  void _handleSearchChanged(String value) {
    setState(() {});
    _cubit.loadBrands(search: value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _cubit.loadBrands();
  }

  void _openBrandFormSheet({BrandEntity? brand}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (_) => BrandFormSheet(
        brand: brand,
        onSubmit: (draft) {
          if (brand == null) {
            _cubit.createBrand(draft);
          } else {
            _cubit.updateBrand(brand.id!, draft);
          }
        },
      ),
    );
  }

  void _confirmDeleteBrand(BrandEntity brand) {
    showDialog(
      context: context,
      builder: (_) => BrandDeleteDialog(
        brand: brand,
        onConfirm: () {
          if (brand.id != null) _cubit.deleteBrand(brand.id!);
        },
      ),
    );
  }

  void _listenToBrandState(BuildContext context, BrandState state) {
    if (state case BrandLoaded(message: final message?)) {
      _showSnack(message, isError: false);
    } else if (state case BrandError(message: final message)) {
      _showSnack(message, isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandManagementAppBar(
        onCreate: () => _openBrandFormSheet(),
      ),
      body: BlocConsumer<BrandCubit, BrandState>(
        listener: _listenToBrandState,
        builder: (context, state) {
          return Column(
            children: [
              BrandSearchBar(
                controller: _searchController,
                onChanged: _handleSearchChanged,
                onClear: _clearSearch,
              ),
              Expanded(
                child: _BrandContent(
                  state: state,
                  onEdit: (brand) => _openBrandFormSheet(brand: brand),
                  onDelete: _confirmDeleteBrand,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandContent extends StatelessWidget {
  final BrandState state;
  final ValueChanged<BrandEntity> onEdit;
  final ValueChanged<BrandEntity> onDelete;

  const _BrandContent({
    required this.state,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      BrandLoading() => const BrandLoadingView(),
      BrandLoaded(:final brands) when brands.isEmpty => const BrandEmptyView(),
      BrandLoaded(:final brands) => _BrandList(
          brands: brands,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      BrandError(:final message) => BrandErrorView(message: message),
      _ => const BrandErrorView(message: 'Đã xảy ra lỗi khi tải dữ liệu.'),
    };
  }
}

class _BrandList extends StatelessWidget {
  final List<BrandEntity> brands;
  final ValueChanged<BrandEntity> onEdit;
  final ValueChanged<BrandEntity> onDelete;

  const _BrandList({
    required this.brands,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];

        return BrandCard(
          brand: brand,
          onToggleStatus: (value) {
            if (brand.id != null) {
              context.read<BrandCubit>().toggleBrandStatus(brand.id!, value);
            }
          },
          onEdit: () => onEdit(brand),
          onDelete: () => onDelete(brand),
        );
      },
    );
  }
}
