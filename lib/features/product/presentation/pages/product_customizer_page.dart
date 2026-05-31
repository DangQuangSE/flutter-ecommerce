import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/customization_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/customizer_state.dart';

class ProductCustomizerPage extends StatefulWidget {
  final String productId;
  final String productName;

  const ProductCustomizerPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductCustomizerPage> createState() => _ProductCustomizerPageState();
}

class _ProductCustomizerPageState extends State<ProductCustomizerPage> {
  // Active custom parameters
  late String _customText;
  late String _textColorName;
  late int _colorHex;
  late String _printMethod;
  late bool _logoEnabled;
  late double _textScale;

  late TextEditingController _textController;
  bool _isAdvancedExpanded = false;

  final List<Map<String, dynamic>> _colorsList = [
    {'name': 'Jet Black', 'hex': 0xFF1A1C1F, 'color': const Color(0xFF1A1C1F)},
    {'name': 'Pure White', 'hex': 0xFFFFFFFF, 'color': const Color(0xFFFFFFFF)},
    {'name': 'Crimson Red', 'hex': 0xFFBA1A1A, 'color': const Color(0xFFBA1A1A)},
    {'name': 'Electric Blue', 'hex': 0xFF0058BC, 'color': const Color(0xFF0058BC)},
    {'name': 'Safety Orange', 'hex': 0xFFFE9400, 'color': const Color(0xFFFE9400)},
  ];

  @override
  void initState() {
    super.initState();
    // Load initial or previously saved customization settings
    final cubit = context.read<CustomizerCubit>();
    final saved = cubit.getCustomizationOrDefault(widget.productId);

    _customText = saved.customText;
    _textColorName = saved.textColor;
    _colorHex = saved.colorHex;
    _printMethod = saved.printMethod;
    _logoEnabled = saved.logoEnabled;
    _textScale = saved.textScale;

    _textController = TextEditingController(text: _customText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final customization = CustomizationEntity(
      productId: widget.productId,
      customText: _customText,
      textColor: _textColorName,
      colorHex: _colorHex,
      printMethod: _printMethod,
      logoEnabled: _logoEnabled,
      textScale: _textScale,
    );

    context.read<CustomizerCubit>().saveCustomization(widget.productId, customization);

    // Show a premium toast feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Đã thiết kế sản phẩm thành công!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to cart checkout
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTextColor = Color(_colorHex);

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDF2), // Studio grey background
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 1. Interactive Canvas Workspace
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient backdrop
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85,
                      colors: [
                        Color(0xFFF9F9FE),
                        Color(0xFFEDEDF2),
                      ],
                    ),
                  ),
                ),

                // Interactive White athletic tee canvas
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // White Athletic T-Shirt image mockup
                        Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAg16llodl6Hl8MPqH6DvSysphHsH9azINDafCIQFp9rqCHyIEj5IyNuBfAVIK7-s1m70zLJYYuRDn7ps4e9BkxeY1wfIJ58BidKV1GgULrOntZ7svsuNpwj8nvPhazvHISS-5OqI81qGvWmbwLlQlDr7PaeNVO1DpmYgljTca2s33rrrPqLBq7MLlaEkQdj7fqz_fN5K-XrOluv8Ux-V0w9V8-aE1C5t5BlJtTl7b0-7Tot4btl19oWsO5WWVz6wdqu1TcpvcIJ6k',
                          fit: BoxFit.contain,
                        ),

                        // Interactive custom overlays positioned on chest
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.12,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Optional logo preview
                              if (_logoEnabled)
                                Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: activeTextColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: activeTextColor, width: 1.5),
                                  ),
                                  child: Icon(
                                    Icons.sports_soccer_rounded,
                                    size: 16,
                                    color: activeTextColor,
                                  ),
                                ),

                              // Customizable text with dashed editor boundaries
                              if (_customText.trim().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1,
                                      style: BorderStyle.solid, // Dynamic editor feel
                                    ),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Slanted Lexend title mimicking styled graphic text
                                      Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.skewX(-0.15),
                                        child: Text(
                                          _customText.toUpperCase(),
                                          style: GoogleFonts.lexend(
                                            fontSize: 22 * _textScale,
                                            fontWeight: FontWeight.w900,
                                            fontStyle: FontStyle.italic,
                                            color: activeTextColor,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),

                                      // Tiny editor handles to feel high-fidelity
                                      Positioned(
                                        top: -14,
                                        right: -22,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _customText = '';
                                              _textController.clear();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(color: Colors.black12, blurRadius: 4),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              size: 10,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -14,
                                        right: -22,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black12, blurRadius: 4),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.open_in_full_rounded,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Floating action controls (right edge)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFloatingBtn(
                          icon: Icons.text_fields_rounded,
                          tooltip: 'Add Text',
                          onTap: () {
                            setState(() {
                              _customText = 'TEAM SPORT';
                              _textController.text = 'TEAM SPORT';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFloatingBtn(
                          icon: Icons.image_outlined,
                          tooltip: 'Toggle Logo',
                          isActive: _logoEnabled,
                          onTap: () {
                            setState(() {
                              _logoEnabled = !_logoEnabled;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFloatingBtn(
                          icon: Icons.palette_outlined,
                          tooltip: 'Palette',
                          onTap: () {
                            // Cycle colors
                            final nextIndex = (_colorsList.indexWhere((c) => c['hex'] == _colorHex) + 1) % _colorsList.length;
                            setState(() {
                              _textColorName = _colorsList[nextIndex]['name'];
                              _colorHex = _colorsList[nextIndex]['hex'];
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFloatingBtn(
                          icon: Icons.layers_outlined,
                          tooltip: 'Layers',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lớp in ấn: Base T-Shirt > Graphic Text > Logo', style: GoogleFonts.inter()),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Configuration Sheet
          _buildConfigurationPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          height: 1,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.cart);
          }
        },
        icon: const Icon(
          Icons.close_rounded,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform(
            transform: Matrix4.skewX(-0.12),
            child: Text(
              'PRO CUSTOMIZER',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.productName,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: _handleConfirm,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  'DONE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBtn({
    required IconData icon,
    required String tooltip,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildConfigurationPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewPadding.bottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC1C6D7).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Print Method Tabs
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabItem('In chuyển nhiệt'),
                _buildTabItem('Decal'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Label and text input to customize text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHỮ IN NGỰC ÁO',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${_customText.length}/15 ký tự',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _textController,
            maxLength: 15,
            onChanged: (val) {
              setState(() {
                _customText = val;
              });
            },
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Nhập nội dung in lên áo...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: const Color(0xFFF3F3F8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Color Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MÀU SẮC HỌA TIẾT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _textColorName.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _colorsList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = _colorsList[index];
                final bool isSelected = _colorHex == item['hex'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _textColorName = item['name'];
                      _colorHex = item['hex'];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFC1C6D7).withValues(alpha: 0.5),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: item['color'] == Colors.white ? AppColors.textPrimary : Colors.white,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Collapsible Advanced Options
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Tùy chọn nâng cao',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 12),
              onExpansionChanged: (expanded) {
                setState(() {
                  _isAdvancedExpanded = expanded;
                });
              },
              children: [
                Row(
                  children: [
                    Text(
                      'Kích thước chữ:',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _textScale,
                        min: 0.6,
                        max: 1.6,
                        activeColor: AppColors.primary,
                        inactiveColor: const Color(0xFFF3F3F8),
                        onChanged: (val) {
                          setState(() {
                            _textScale = val;
                          });
                        },
                      ),
                    ),
                    Text(
                      '${(_textScale * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    final bool isActive = _printMethod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _printMethod = title;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
