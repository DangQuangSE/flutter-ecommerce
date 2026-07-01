import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_empty_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_state.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_group_card.dart';

class AdminSizeGroupListPage extends StatefulWidget {
  const AdminSizeGroupListPage({super.key});

  @override
  State<AdminSizeGroupListPage> createState() => _AdminSizeGroupListPageState();
}

class _AdminSizeGroupListPageState extends State<AdminSizeGroupListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<SizeGroupCubit>().loadSizeGroups();
    });
  }

  Future<void> _navigateToCreate(BuildContext context) async {
    await context.pushNamed(AppRoutes.adminSizeGroupCreate);
    if (context.mounted) {
      context.read<SizeGroupCubit>().loadSizeGroups();
    }
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    SizeGroupEntity group,
  ) async {
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
      
      appBar: _buildAppBar(),
      body: BlocConsumer<SizeGroupCubit, SizeGroupState>(
        listener: _onStateChange,
        builder: (context, state) => _buildBody(context, state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      title: Text(
        AppStrings.adminSizeGroupTitle,
        style: GoogleFonts.lexend(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.fontXxl,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SizeGroupState state) {
    return switch (state) {
      SizeGroupLoading() => const AppLoadingView(),
      SizeGroupError(:final message) => _buildError(context, message),
      SizeGroupEmpty() => _buildEmpty(context),
      SizeGroupSuccess(:final groups) => _buildList(context, groups),
      SizeGroupInitial() => const AppLoadingView(),
    };
  }

  Widget _buildError(BuildContext context, String message) {
    return AppErrorView(
      title: AppStrings.genericLoadError,
      message: message,
      onRetry: () => context.read<SizeGroupCubit>().loadSizeGroups(),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyView(
      icon: Icons.straighten_rounded,
      title: AppStrings.adminSizeGroupEmpty,
      actionLabel: AppStrings.adminSizeGroupCreateAction,
      onAction: () => _navigateToCreate(context),
    );
  }

  Widget _buildList(BuildContext context, List<SizeGroupEntity> groups) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: AppSizes.paddingSm),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return SizeGroupCard(
          group: group,
          onEdit: () => _navigateToEdit(context, group),
        );
      },
    );
  }

  void _onStateChange(BuildContext context, SizeGroupState state) {
    if (state is SizeGroupSuccess && state.message != null) {
      AppSnackBar.show(
        context,
        message: state.message!,
        type: AppSnackBarType.success,
      );
    } else if (state is SizeGroupError) {
      AppSnackBar.show(
        context,
        message: state.message,
        type: AppSnackBarType.error,
      );
    }
  }
}