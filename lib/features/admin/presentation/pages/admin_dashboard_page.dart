import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/widgets/admin_dashboard_tab.dart';
import 'package:flutter_ecommerce/features/admin/presentation/widgets/admin_management_tab.dart';
import 'package:flutter_ecommerce/features/admin/presentation/widgets/admin_location_tab.dart';
import 'package:flutter_ecommerce/features/admin/presentation/widgets/admin_profile_tab.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            );
          }

          if (state is AdminLoaded) {
            return IndexedStack(
              index: _currentIndex,
              children: [
                AdminDashboardTab(state: state),
                const AdminManagementTab(),
                AdminLocationTab(
                    onBackToDashboard: () => setState(() => _currentIndex = 0)),
                const AdminProfileTab(),
              ],
            );
          }

          return const Center(
              child: Text('Đã xảy ra lỗi khi tải dữ liệu Admin.'));
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary.withOpacity(0.7),
          selectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 22),
                activeIcon: Icon(Icons.dashboard_rounded, size: 24),
                label: 'Tổng quan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.tune_rounded, size: 22),
                activeIcon: Icon(Icons.tune_rounded, size: 24),
                label: 'Quản lý'),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on_rounded, size: 22),
                activeIcon: Icon(Icons.location_on_rounded, size: 24),
                label: 'Cửa hàng'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 22),
                activeIcon: Icon(Icons.person_rounded, size: 24),
                label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }
}
