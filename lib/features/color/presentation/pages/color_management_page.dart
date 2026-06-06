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

class ColorManagementPage extends StatefulWidget {
  const ColorManagementPage({super.key});

  @override
  State<ColorManagementPage> createState() => _ColorManagementPageState();
}

class _ColorManagementPageState extends State<ColorManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
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
            icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
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

  // ── Tab 1: Product Colors ──────────────────────────────────────────────────
  Widget _buildProductColorsTab() {
    return BlocConsumer<ProductColorCubit, ProductColorState>(
      listener: (context, state) {
        if (state is ProductColorLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ProductColorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProductColorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductColorLoaded) {
          final colors = state.colors;
          if (colors.isEmpty) {
            return _buildEmptyState('Chưa có màu sản phẩm nào.');
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return _buildColorCard(
                context: context,
                name: color.name,
                hexCode: color.hexCode,
                onEdit: () => _openProductColorForm(context, color: color),
                onDelete: () => _confirmDeleteProductColor(context, color),
              );
            },
          );
        }

        return const Center(child: Text('Lỗi tải màu sản phẩm.'));
      },
    );
  }

  // ── Tab 2: Printing Colors ──────────────────────────────────────────────────
  Widget _buildPrintingColorsTab() {
    return BlocConsumer<PrintingColorCubit, PrintingColorState>(
      listener: (context, state) {
        if (state is PrintingColorLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is PrintingColorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PrintingColorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PrintingColorLoaded) {
          final colors = state.colors;
          if (colors.isEmpty) {
            return _buildEmptyState('Chưa có màu in ấn nào.');
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return _buildColorCard(
                context: context,
                name: color.name,
                hexCode: color.hexCode,
                isActive: color.isActive,
                onToggleActive: (val) {
                  if (color.id != null) {
                    context.read<PrintingColorCubit>().toggleColorStatus(color.id!, val);
                  }
                },
                onEdit: () => _openPrintingColorForm(context, color: color),
                onDelete: () => _confirmDeletePrintingColor(context, color),
              );
            },
          );
        }

        return const Center(child: Text('Lỗi tải màu in ấn.'));
      },
    );
  }

  Widget _buildColorCard({
    required BuildContext context,
    required String name,
    required String hexCode,
    bool? isActive,
    ValueChanged<bool>? onToggleActive,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final previewColor = _hexToColor(hexCode);
    final bool isDarkColor = ThemeData.estimateBrightnessForColor(previewColor) == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Color Preview Bar
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: previewColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      hexCode,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDarkColor ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (isActive != null && onToggleActive != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? Colors.green.withOpacity(0.85) 
                              : Colors.red.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Disabled',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Color Info & Actions
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Toggle Active if it's printing color
                      if (isActive != null && onToggleActive != null)
                        SizedBox(
                          width: 36,
                          height: 20,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Switch.adaptive(
                              value: isActive,
                              activeColor: AppColors.primary,
                              onChanged: onToggleActive,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                            onPressed: onEdit,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheets and Dialogs ──────────────────────────────────────────────
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

  void _openProductColorForm(BuildContext context, {ProductColorEntity? color}) {
    final bool isEdit = color != null;
    final nameController = TextEditingController(text: color?.name ?? '');
    final hexController = TextEditingController(text: color?.hexCode ?? '#');

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
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Sửa màu sản phẩm' : 'Thêm màu sản phẩm mới',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Name
                    _buildLabel('TÊN MÀU SẮC'),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên màu (ví dụ: Aero Blue)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hex Code
                    _buildLabel('MÃ HEX (HEX CODE)'),
                    TextField(
                      controller: hexController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Nhập mã Hex (ví dụ: #FF6D00)',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.color_lens_outlined, color: AppColors.primary),
                          onPressed: () => _openColorPickerDialog(context, hexController, setSheetState),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Color Preview block
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _hexToColor(hexController.text),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Xem trước màu sắc',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Presets
                    _buildLabel('MÀU ĐÃ CÓ SẴN (GỢI Ý)'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((preset) {
                        final parsedPresetColor = _hexToColor(preset['hex']!);
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              nameController.text = preset['name']!;
                              hexController.text = preset['hex']!;
                            });
                          },
                          child: Chip(
                            backgroundColor: parsedPresetColor.withOpacity(0.12),
                            side: BorderSide(color: parsedPresetColor.withOpacity(0.3)),
                            avatar: CircleAvatar(
                              radius: 8,
                              backgroundColor: parsedPresetColor,
                            ),
                            label: Text(
                              preset['name']!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final hex = hexController.text.trim().toUpperCase();

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập tên màu!'), backgroundColor: AppColors.error),
                          );
                          return;
                        }

                        final regex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
                        if (!regex.hasMatch(hex)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mã HEX không hợp lệ! Vui lòng bắt đầu với # và có 3 hoặc 6 ký tự số/chữ.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        final colorEntity = ProductColorEntity(
                          id: color?.id,
                          name: name,
                          hexCode: hex,
                        );

                        if (isEdit) {
                          context.read<ProductColorCubit>().updateColor(color.id!, colorEntity);
                        } else {
                          context.read<ProductColorCubit>().createColor(colorEntity);
                        }

                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'LƯU THAY ĐỔI' : 'THÊM MÀU SẢN PHẨM',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openPrintingColorForm(BuildContext context, {PrintingColorEntity? color}) {
    final bool isEdit = color != null;
    final nameController = TextEditingController(text: color?.name ?? '');
    final hexController = TextEditingController(text: color?.hexCode ?? '#');
    bool activeVal = color?.isActive ?? true;

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
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Sửa màu in ấn' : 'Thêm màu in ấn mới',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Name
                    _buildLabel('TÊN MÀU IN'),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên màu in (ví dụ: Gold Foil)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hex Code
                    _buildLabel('MÃ HEX (HEX CODE)'),
                    TextField(
                      controller: hexController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Nhập mã Hex (ví dụ: #D4AF37)',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.color_lens_outlined, color: AppColors.primary),
                          onPressed: () => _openColorPickerDialog(context, hexController, setSheetState),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Color Preview
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _hexToColor(hexController.text),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Xem trước màu sắc',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Presets
                    _buildLabel('MÀU ĐÃ CÓ SẴN (GỢI Ý)'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((preset) {
                        final parsedPresetColor = _hexToColor(preset['hex']!);
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              nameController.text = preset['name']!;
                              hexController.text = preset['hex']!;
                            });
                          },
                          child: Chip(
                            backgroundColor: parsedPresetColor.withOpacity(0.12),
                            side: BorderSide(color: parsedPresetColor.withOpacity(0.3)),
                            avatar: CircleAvatar(
                              radius: 8,
                              backgroundColor: parsedPresetColor,
                            ),
                            label: Text(
                              preset['name']!,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('TRẠNG THÁI HOẠT ĐỘNG'),
                        Switch.adaptive(
                          value: activeVal,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setSheetState(() {
                              activeVal = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final hex = hexController.text.trim().toUpperCase();

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập tên màu in!'), backgroundColor: AppColors.error),
                          );
                          return;
                        }

                        final regex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
                        if (!regex.hasMatch(hex)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mã HEX không hợp lệ!'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        final colorEntity = PrintingColorEntity(
                          id: color?.id,
                          name: name,
                          hexCode: hex,
                          isActive: activeVal,
                        );

                        if (isEdit) {
                          context.read<PrintingColorCubit>().updateColor(color.id!, colorEntity);
                        } else {
                          context.read<PrintingColorCubit>().createColor(colorEntity);
                        }

                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'LƯU THAY ĐỔI' : 'THÊM MÀU IN ẤN',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openColorPickerDialog(
    BuildContext context,
    TextEditingController hexController,
    StateSetter setSheetState,
  ) {
    Color initColor = _hexToColor(hexController.text);
    showDialog(
      context: context,
      builder: (diagContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Chọn màu sắc',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initColor,
              onColorChanged: (color) {
                final hexStr = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                hexController.text = hexStr;
                setSheetState(() {});
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(diagContext),
              child: Text(
                'XONG',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _confirmDeleteProductColor(BuildContext context, ProductColorEntity color) {
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa màu sản phẩm?', style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
        content: Text('Bạn có chắc muốn xóa màu "${color.name}" khỏi sản phẩm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text('HỦY', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (color.id != null) {
                context.read<ProductColorCubit>().deleteColor(color.id!);
              }
              Navigator.pop(diagContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePrintingColor(BuildContext context, PrintingColorEntity color) {
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa màu in ấn?', style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
        content: Text('Bạn có chắc muốn xóa màu in ấn "${color.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text('HỦY', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (color.id != null) {
                context.read<PrintingColorCubit>().deleteColor(color.id!);
              }
              Navigator.pop(diagContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }
}
