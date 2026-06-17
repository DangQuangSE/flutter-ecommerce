import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class AdminManagementTab extends StatelessWidget {
  const AdminManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Text(
            'Quản lý',
            style: GoogleFonts.lexend(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Truy cập nhanh các mục quản trị',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _item(context, icon: Icons.shopping_bag_rounded, label: 'Quản lý Sản phẩm', onTap: () => context.pushNamed(AppRoutes.adminProductList)),
                const Divider(height: 1),
                _item(context, icon: Icons.branding_watermark_rounded, label: 'Quản lý Thương hiệu', onTap: () => context.pushNamed(AppRoutes.adminBrands)),
                const Divider(height: 1),
                _item(context, icon: Icons.color_lens_rounded, label: 'Quản lý Màu sắc', onTap: () => context.pushNamed(AppRoutes.adminColors)),
                const Divider(height: 1),
                _item(context, icon: Icons.category_rounded, label: 'Quản lý Danh mục', onTap: () => context.pushNamed(AppRoutes.adminCategories)),
                const Divider(height: 1),
                _item(context, icon: Icons.local_offer_rounded, label: 'Quản lý Mã giảm giá', onTap: () => context.pushNamed(AppRoutes.adminCoupons)),
                const Divider(height: 1),
                _item(context, icon: Icons.straighten_rounded, label: 'Quản lý Kích thước', onTap: () => context.pushNamed(AppRoutes.adminSizeGroups)),
                const Divider(height: 1),
                _item(context, icon: Icons.support_agent_rounded, label: 'Tin nhắn hỗ trợ', onTap: () => context.pushNamed(AppRoutes.chatList)),
                const Divider(height: 1),
                _item(context, icon: Icons.policy_rounded, label: 'Chính sách đổi trả & bảo hành', onTap: () => context.pushNamed(AppRoutes.adminSiteSettings)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }
}
