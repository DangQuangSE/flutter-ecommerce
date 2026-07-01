import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/notification/presentation/widgets/notification_bell_icon.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _picker = ImagePicker();

  bool _prefilled = false;
  bool _submitting = false;
  bool _uploadingAvatar = false;
  File? _pickedAvatar;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final state = context.read<ProfileCubit>().state;
      if (state is ProfileLoaded) _prefill(state.profile);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _prefill(ProfileEntity profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _prefilled = true;
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _pickedAvatar = File(picked.path);
      _uploadingAvatar = true;
    });
    final error =
        await context.read<ProfileCubit>().updateAvatar(File(picked.path));
    if (!mounted) return;
    setState(() => _uploadingAvatar = false);
    _showSnack(
      error ?? AppStrings.editProfileAvatarUpdated,
      isError: error != null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final error = await context.read<ProfileCubit>().updateName(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error == null) {
      _showSnack(AppStrings.editProfileSaved);
      if (context.canPop()) context.pop();
    } else {
      _showSnack(error, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnackBar.show(
      context,
      message: message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // Prefill once the profile arrives (if it wasn't ready in initState).
        if (state is ProfileLoaded && !_prefilled) {
          setState(() => _prefill(state.profile));
        }
      },
      child: Scaffold(
        
        appBar: _buildAppBar(context),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final profile = state is ProfileLoaded ? state.profile : null;
            if (profile == null && state is ProfileLoading) {
              return const AppLoadingView();
            }
            return _buildForm(context, profile);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProfileEntity? profile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSizes.paddingMd),
            _buildAvatarSection(profile?.avatar),
            SizedBox(height: AppSizes.fontDisplay),
            _buildLabel(AppStrings.editProfileFirstNameLabel),
            SizedBox(height: AppSizes.radiusSm),
            _buildTextField(
              controller: _firstNameController,
              hint: AppStrings.editProfileFirstNameHint,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.editProfileFirstNameRequired
                  : null,
            ),
            SizedBox(height: AppSizes.paddingLg),
            _buildLabel(AppStrings.editProfileLastNameLabel),
            SizedBox(height: AppSizes.radiusSm),
            _buildTextField(
              controller: _lastNameController,
              hint: AppStrings.editProfileLastNameHint,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.editProfileLastNameRequired
                  : null,
            ),
            SizedBox(height: AppSizes.paddingLg),
            _buildLabel(AppStrings.editProfileEmailLabel),
            SizedBox(height: AppSizes.radiusSm),
            _buildReadOnlyEmail(profile?.email ?? ''),
            SizedBox(height: AppSizes.fontDisplay),
            _buildSaveButton(),
            SizedBox(height: AppSizes.fontDisplay),
          ],
        ),
      ),
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────────────
  Widget _buildAvatarSection(String? avatarUrl) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildAvatarImage(avatarUrl),
          ),
          if (_uploadingAvatar)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
                child: Center(
                  child: AppLoadingView(
                    size: AppSizes.paddingXl,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 8,
            child: GestureDetector(
              onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String? avatarUrl) {
    if (_pickedAvatar != null) {
      return Image.file(_pickedAvatar!, fit: BoxFit.cover);
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(),
      );
    }
    return _avatarFallback();
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFFF3F3F8),
      child: Icon(Icons.person_rounded,
          size: 40, color: AppColors.textSecondary),
    );
  }

  // ── Fields ─────────────────────────────────────────────────────────────────
  Widget _buildReadOnlyEmail(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F8),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: const Color(0xFFC1C6D7).withValues(alpha: 0.3)),
      ),
      child: Text(
        email,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _submitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _submitting
          ? const AppLoadingView(size: AppSizes.iconMd, color: Colors.white)
          : Text(
              AppStrings.editProfileSaveChanges,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF3F3F8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.error),
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
            context.goNamed(AppRoutes.profile);
          }
        },
        icon: Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary, size: 24),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Transform(
          transform: Matrix4.skewX(-0.15),
          child: Text(
            'Sport Pro',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
              letterSpacing: -1.2,
            ),
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        const NotificationBellIcon(),
        BlocBuilder<ChatCubit, ChatState>(
          builder: (context, chatState) {
            final unreadCount = context.read<ChatCubit>().totalUnreadMessages;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => context.goNamed(AppRoutes.chatList),
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$unreadCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(width: 12),
      ],
    );
  }
}
