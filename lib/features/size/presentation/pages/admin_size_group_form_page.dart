import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_option_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_state.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_group_form_fields.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_option_draft.dart';
import 'package:flutter_ecommerce/features/size/presentation/widgets/size_option_list_editor.dart';

class AdminSizeGroupFormPage extends StatefulWidget {
  final SizeGroupEntity? initialGroup;

  const AdminSizeGroupFormPage({super.key, this.initialGroup});

  @override
  State<AdminSizeGroupFormPage> createState() => _AdminSizeGroupFormPageState();
}

class _AdminSizeGroupFormPageState extends State<AdminSizeGroupFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late List<SizeOptionDraft> _drafts;

  bool get _isEdit => widget.initialGroup != null;

  @override
  void initState() {
    super.initState();
    final group = widget.initialGroup;
    _nameCtrl = TextEditingController(text: group?.name ?? '');
    _descCtrl = TextEditingController(text: group?.description ?? '');
    _drafts = group?.sizes
            .map((size) => SizeOptionDraft(
                  name: size.name,
                  displayOrder: size.displayOrder,
                ))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SizeGroupCubit, SizeGroupState>(
      listener: _onStateChange,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizeGroupNameField(controller: _nameCtrl),
                const SizedBox(height: 12),
                SizeGroupDescriptionField(controller: _descCtrl),
                const SizedBox(height: AppSizes.paddingLg),
                SizeOptionListEditor(
                  drafts: _drafts,
                  onAdd: _addDraft,
                  onRemove: _removeDraft,
                  onChanged: _updateDraft,
                ),
                AppSizes.spacingLg,
                SizeGroupSaveButton(onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      title: Text(
        _isEdit ? AppStrings.adminSizeGroupEditTitle : AppStrings.adminSizeGroupCreateTitle,
        style: GoogleFonts.lexend(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.fontXxl,
        ),
      ),
    );
  }

  void _addDraft() {
    setState(() {
      _drafts = [
        ..._drafts,
        SizeOptionDraft(name: '', displayOrder: _drafts.length),
      ];
    });
  }

  void _removeDraft(int index) {
    setState(() {
      _drafts = List.from(_drafts)..removeAt(index);
    });
  }

  void _updateDraft(int index, SizeOptionDraft updated) {
    setState(() {
      final list = List<SizeOptionDraft>.from(_drafts);
      list[index] = updated;
      _drafts = list;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final entity = SizeGroupEntity(
      id: widget.initialGroup?.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      sizes: _drafts
          .map(
            (draft) => SizeOptionEntity(
              name: draft.name.trim(),
              displayOrder: draft.displayOrder,
            ),
          )
          .toList(),
    );
    final cubit = context.read<SizeGroupCubit>();
    if (_isEdit) {
      cubit.updateSizeGroup(widget.initialGroup!.id!, entity);
    } else {
      cubit.createSizeGroup(entity);
    }
  }

  void _onStateChange(BuildContext context, SizeGroupState state) {
    if (state is SizeGroupSuccess && state.message != null) {
      Navigator.of(context).pop();
    } else if (state is SizeGroupError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
