import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class AdminManagementTab extends StatelessWidget {
  const AdminManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLg, vertical: AppSizes.paddingXl),
        children: [
          Text(
            AppStrings.adminManagementTitle,
            style: GoogleFonts.lexend(
                fontSize: AppSizes.fontTitle,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: AppSizes.paddingXs),
          Text(
            AppStrings.adminManagementSubtitle,
            style: GoogleFonts.inter(
                fontSize: AppSizes.font13, color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSizes.paddingXl),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _item(context,
                    icon: Icons.shopping_bag_rounded,
                    label: AppStrings.adminManageProducts,
                    onTap: () => context.pushNamed(AppRoutes.adminProductList)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.branding_watermark_rounded,
                    label: AppStrings.adminManageBrands,
                    onTap: () => context.pushNamed(AppRoutes.adminBrands)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.color_lens_rounded,
                    label: AppStrings.adminManageColors,
                    onTap: () => context.pushNamed(AppRoutes.adminColors)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.category_rounded,
                    label: AppStrings.adminManageCategories,
                    onTap: () =>
                        context.pushNamed(AppRoutes.adminCategories)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.local_offer_rounded,
                    label: AppStrings.adminManageCoupons,
                    onTap: () => context.pushNamed(AppRoutes.adminCoupons)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.reviews_rounded,
                    label: AppStrings.adminReviewsManagementLabel,
                    onTap: () => context.pushNamed(AppRoutes.adminReviews)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.straighten_rounded,
                    label: AppStrings.adminManageSizes,
                    onTap: () =>
                        context.pushNamed(AppRoutes.adminSizeGroups)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.support_agent_rounded,
                    label: AppStrings.adminSupportMessages,
                    onTap: () => context.pushNamed(AppRoutes.chatList)),
                const Divider(height: 1),
                _item(context,
                    icon: Icons.policy_rounded,
                    label: AppStrings.adminReturnPolicy,
                    onTap: () =>
                        context.pushNamed(AppRoutes.adminSiteSettings)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label,
          style: GoogleFonts.inter(
              fontSize: AppSizes.fontLg, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: AppSizes.fontLg),
      onTap: onTap,
    );
  }
}
