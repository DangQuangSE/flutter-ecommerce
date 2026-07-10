import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_state.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_order_list_page.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/store_location_picker_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';
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
  AdminOrderCubit? _adminOrderCubit;
  ShopCubit? _shopCubit;

  /// Built lazily so the Location tab's real map + shop load only fire once the
  /// admin actually opens that tab (R10 — IndexedStack is eager).
  bool _locationVisited = false;
  static const int _locationTabIndex = 3;

  AdminOrderCubit get _ordersCubit {
    return _adminOrderCubit ??= sl<AdminOrderCubit>()..loadOrders();
  }

  ShopCubit get _shopConfigCubit {
    return _shopCubit ??= sl<ShopCubit>()..loadShop();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == _locationTabIndex) _locationVisited = true;
    });
  }

  /// Location tab, provided with its cubits and built only after first visit.
  Widget _buildLocationTab() {
    if (!_locationVisited) return const SizedBox.shrink();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _shopConfigCubit),
        BlocProvider(create: (_) => sl<StoreLocationPickerCubit>()),
      ],
      child: AdminLocationTab(
        onBackToDashboard: () => setState(() => _currentIndex = 0),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ChatCubit>().loadChats();
    });
  }

  @override
  void dispose() {
    _adminOrderCubit?.close();
    _shopCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return Center(
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
                BlocProvider.value(
                  value: _ordersCubit,
                  child: const AdminOrderListPage(showAppBar: false),
                ),
                _buildLocationTab(),
                const AdminProfileTab(),
              ],
            );
          }

          return Center(child: Text(AppStrings.adminDashboardLoadError));
        },
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.88),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor:
                  AppColors.textSecondary.withValues(alpha: 0.7),
              selectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, fontSize: AppSizes.fontSm),
              unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w500, fontSize: AppSizes.fontSm),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_rounded, size: AppSizes.iconNav),
                    activeIcon: Icon(Icons.dashboard_rounded,
                        size: AppSizes.iconNavActive),
                    label: AppStrings.adminNavOverview),
                BottomNavigationBarItem(
                    icon: Icon(Icons.tune_rounded, size: AppSizes.iconNav),
                    activeIcon:
                        Icon(Icons.tune_rounded, size: AppSizes.iconNavActive),
                    label: AppStrings.adminNavManagement),
                BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_rounded,
                        size: AppSizes.iconNav),
                    activeIcon: Icon(Icons.receipt_long_rounded,
                        size: AppSizes.iconNavActive),
                    label: AppStrings.adminNavOrders),
                BottomNavigationBarItem(
                    icon:
                        Icon(Icons.location_on_rounded, size: AppSizes.iconNav),
                    activeIcon: Icon(Icons.location_on_rounded,
                        size: AppSizes.iconNavActive),
                    label: AppStrings.adminNavStore),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded, size: AppSizes.iconNav),
                    activeIcon: Icon(Icons.person_rounded,
                        size: AppSizes.iconNavActive),
                    label: AppStrings.adminNavProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
