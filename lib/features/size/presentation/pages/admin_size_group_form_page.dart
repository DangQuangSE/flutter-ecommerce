import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_option_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_state.dart';
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
    final g = widget.initialGroup;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _descCtrl = TextEditingController(text: g?.description ?? '');
    _drafts = g?.sizes
            .map((s) =>
                SizeOptionDraft(name: s.name, displayOrder: s.displayOrder))
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
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NameField(controller: _nameCtrl),
                const SizedBox(height: 12),
                _DescriptionField(controller: _descCtrl),
                const SizedBox(height: 20),
                SizeOptionListEditor(
                  drafts: _drafts,
                  onAdd: _addDraft,
                  onRemove: _removeDraft,
                  onChanged: _updateDraft,
                ),
                const SizedBox(height: 24),
                _SaveButton(onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      title: Text(
        _isEdit ? 'Sửa nhóm kích thước' : 'Tạo nhóm kích thước',
        style: GoogleFonts.lexend(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  void _addDraft() {
    setState(() {
      _drafts = [
        ..._drafts,
        SizeOptionDraft(name: '', displayOrder: _drafts.length)
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
          .map((d) => SizeOptionEntity(
              name: d.name.trim(), displayOrder: d.displayOrder))
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

class _NameField extends StatelessWidget {
  final TextEditingController controller;

  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Tên nhóm kích thước *',
        border: OutlineInputBorder(),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
      maxLength: 100,
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Mô tả (tuỳ chọn)',
        border: OutlineInputBorder(),
      ),
      maxLength: 255,
      maxLines: 2,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Lưu',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
