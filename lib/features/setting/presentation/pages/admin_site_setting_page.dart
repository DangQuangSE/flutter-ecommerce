import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_state.dart';

class AdminSiteSettingPage extends StatefulWidget {
  const AdminSiteSettingPage({super.key});

  @override
  State<AdminSiteSettingPage> createState() => _AdminSiteSettingPageState();
}

class _AdminSiteSettingPageState extends State<AdminSiteSettingPage> {
  final TextEditingController _returnPolicyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  @override
  void dispose() {
    _returnPolicyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chính sách đổi trả & bảo hành',
          style: GoogleFonts.lexend(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: BlocConsumer<SiteSettingCubit, SiteSettingState>(
          listener: (context, state) {
            if (state is SiteSettingLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is SiteSettingError) {
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
            if (state is SiteSettingLoading || state is SiteSettingInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is SiteSettingLoaded) {
              if (!_isInitialized) {
                _returnPolicyController.text = state.settings.returnPolicy;
                _isInitialized = true;
              }
              return _buildForm(context, state.isSubmitting);
            }

            return _buildErrorState(context);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isSubmitting) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nội dung này sẽ hiển thị cho khách hàng ở trang chi tiết sản phẩm.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Expanded(
              child: TextFormField(
                controller: _returnPolicyController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung chính sách đổi trả & bảo hành...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Nội dung chính sách không được để trống'
                    : null,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSubmitting ? null : () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Lưu thay đổi',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<SiteSettingCubit>()
          .updateReturnPolicy(_returnPolicyController.text.trim());
    }
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi khi tải dữ liệu.',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<SiteSettingCubit>().loadSettings(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}