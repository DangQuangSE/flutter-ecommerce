import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_state.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_group_card.dart';

class AdminSizeGroupListPage extends StatelessWidget {
  const AdminSizeGroupListPage({super.key});

  Future<void> _navigateToCreate(BuildContext context) async {
    await context.pushNamed(AppRoutes.adminSizeGroupCreate);
    if (context.mounted) {
      context.read<SizeGroupCubit>().loadSizeGroups();
    }
  }

  Future<void> _navigateToEdit(
      BuildContext context, SizeGroupEntity group) async {
    await context.pushNamed(
      AppRoutes.adminSizeGroupEdit,
      pathParameters: {'id': group.id.toString()},
      extra: group,
    );
    if (context.mounted) {
      context.read<SizeGroupCubit>().loadSizeGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<SizeGroupCubit, SizeGroupState>(
        listener: _onStateChange,
        builder: (ctx, state) => _buildBody(ctx, state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      title: Text(
        'Nhóm kích thước',
        style: GoogleFonts.lexend(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SizeGroupState state) {
    return switch (state) {
      SizeGroupLoading() => _buildLoading(),
      SizeGroupError(:final message) => _buildError(context, message),
      SizeGroupEmpty() => _buildEmpty(context),
      SizeGroupSuccess(:final groups) => _buildList(context, groups),
      SizeGroupInitial() => _buildLoading(),
    };
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<SizeGroupCubit>().loadSizeGroups(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.straighten_rounded,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'Chưa có nhóm kích thước nào',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _navigateToCreate(context),
            child: const Text('Tạo mới'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<SizeGroupEntity> groups) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: groups.length,
      itemBuilder: (ctx, i) {
        final group = groups[i];
        return SizeGroupCard(
          group: group,
          onEdit: () => _navigateToEdit(context, group),
        );
      },
    );
  }

  void _onStateChange(BuildContext context, SizeGroupState state) {
    if (state is SizeGroupSuccess && state.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message!),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is SizeGroupError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
