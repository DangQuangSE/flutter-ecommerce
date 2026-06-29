import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/printing_color_entity.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_state.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_state.dart';

part 'color_management_dialogs.dart';
part 'color_management_cards.dart';
part 'color_management_printing_form.dart';
part 'color_management_product_form.dart';
part 'color_management_tabs.dart';

class ColorManagementPage extends StatefulWidget {
  const ColorManagementPage({super.key});

  @override
  State<ColorManagementPage> createState() => _ColorManagementPageState();
}

class _ColorManagementPageState extends State<ColorManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, String>> _presets = const [
    {'name': 'Đen Jet', 'hex': '#000000'},
    {'name': 'Trắng Chalk', 'hex': '#FFFFFF'},
    {'name': 'Đỏ Crimson', 'hex': '#DC143C'},
    {'name': 'Xanh Cobalt', 'hex': '#0047AB'},
    {'name': 'Vàng Neon', 'hex': '#E0FF00'},
    {'name': 'Cam Hổ Phách', 'hex': '#FFBF00'},
    {'name': 'Lục Emerald', 'hex': '#50C878'},
    {'name': 'Tím Lavender', 'hex': '#E6E6FA'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hexCode) {
    try {
      String cleanHex = hexCode.replaceAll('#', '').trim();
      if (cleanHex.length == 3) {
        cleanHex = cleanHex.split('').map((c) => '$c$c').join();
      }
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Quản lý Màu sắc',
          style: GoogleFonts.lexend(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle:
              GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Màu sản phẩm'),
            Tab(text: 'Màu in ấn'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _openProductColorForm(context);
              } else {
                _openPrintingColorForm(context);
              }
            },
            icon: const Icon(Icons.add_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductColorsTab(),
          _buildPrintingColorsTab(),
        ],
      ),
    );
  }
}
