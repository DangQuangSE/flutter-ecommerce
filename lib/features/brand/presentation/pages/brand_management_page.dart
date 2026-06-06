import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_cubit.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Thương hiệu',
          style: GoogleFonts.lexend(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            onPressed: () => _openBrandFormSheet(context),
            icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<BrandCubit, BrandState>(
        listener: (context, state) {
          if (state is BrandLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is BrandError) {
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
          return Column(
            children: [
              // Search Bar Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<BrandCubit>().loadBrands(search: val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thương hiệu...',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              context.read<BrandCubit>().loadBrands();
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                    ),
                  ),
                ),
              ),
              
              // Brands Content
              Expanded(
                child: _buildBody(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BrandState state) {
    if (state is BrandLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (state is BrandLoaded) {
      final brands = state.brands;
      if (brands.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.branding_watermark_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy thương hiệu nào',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return _buildBrandCard(context, brand);
        },
      );
    }

    return Center(
      child: Text(
        'Đã xảy ra lỗi khi tải dữ liệu.',
        style: GoogleFonts.inter(color: AppColors.error),
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, BrandEntity brand) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Brand logo / Initials avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: brand.logoUrl.isNotEmpty
                        ? Image.network(
                            brand.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackAvatar(brand.name),
                          )
                        : _buildFallbackAvatar(brand.name),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Name & Country
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.public_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            brand.country.isNotEmpty ? brand.country : 'Chưa có thông tin quốc gia',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Switch
                Switch.adaptive(
                  value: brand.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (brand.id != null) {
                      context.read<BrandCubit>().toggleBrandStatus(brand.id!, val);
                    }
                  },
                ),
              ],
            ),
            
            // Description
            if (brand.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                brand.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Website URL & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: brand.websiteUrl.isNotEmpty
                      ? Row(
                          children: [
                            const Icon(Icons.link_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                brand.websiteUrl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ),
                Row(
                  children: [
                    // Edit
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _openBrandFormSheet(context, brand: brand),
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 16),
                    // Delete
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDeleteBrand(context, brand),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.lexend(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _openBrandFormSheet(BuildContext context, {BrandEntity? brand}) {
    final bool isEdit = brand != null;
    final nameController = TextEditingController(text: brand?.name ?? '');
    final descController = TextEditingController(text: brand?.description ?? '');
    final logoController = TextEditingController(text: brand?.logoUrl ?? '');
    final countryController = TextEditingController(text: brand?.country ?? '');
    final webController = TextEditingController(text: brand?.websiteUrl ?? '');
    bool activeVal = brand?.isActive ?? true;

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
                          isEdit ? 'Chỉnh sửa thương hiệu' : 'Thêm thương hiệu mới',
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
                    _buildLabel('TÊN THƯƠNG HIỆU'),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên thương hiệu (ví dụ: Nike)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Country
                    _buildLabel('QUỐC GIA'),
                    TextField(
                      controller: countryController,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: USA, Vietnam',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Website URL
                    _buildLabel('WEBSITE'),
                    TextField(
                      controller: webController,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: https://www.nike.com',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logo URL
                    _buildLabel('LOGO URL'),
                    TextField(
                      controller: logoController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập URL hình ảnh logo',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('MÔ TẢ'),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Nhập mô tả về thương hiệu...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // IsActive Toggle
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

                    // Submit Action
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.length < 2 || name.length > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tên thương hiệu phải từ 2 đến 100 ký tự!'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        final brandEntity = BrandEntity(
                          id: brand?.id,
                          name: name,
                          slug: brand?.slug ?? '',
                          description: descController.text.trim(),
                          logoUrl: logoController.text.trim(),
                          country: countryController.text.trim(),
                          websiteUrl: webController.text.trim(),
                          isActive: activeVal,
                        );

                        if (isEdit) {
                          context.read<BrandCubit>().updateBrand(brand.id!, brandEntity);
                        } else {
                          context.read<BrandCubit>().createBrand(brandEntity);
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
                        elevation: 1,
                      ),
                      child: Text(
                        isEdit ? 'LƯU THAY ĐỔI' : 'THÊM THƯƠNG HIỆU',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
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

  void _confirmDeleteBrand(BuildContext context, BrandEntity brand) {
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Xóa thương hiệu?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa thương hiệu "${brand.name}"? Hành động này không thể hoàn tác.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text(
              'HỦY',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (brand.id != null) {
                context.read<BrandCubit>().deleteBrand(brand.id!);
              }
              Navigator.pop(diagContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'XÓA',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
