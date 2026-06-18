import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/variant_edit_dialog.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';

part 'bulk_variant_selection.dart';
part 'bulk_variant_preview.dart';

// ── Shared helper ─────────────────────────────────────────────────────────────

Color _hexColor(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

Widget _sectionLabel(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
    );

// ── Main widget ───────────────────────────────────────────────────────────────

class BulkVariantSheet extends StatefulWidget {
  final List<SizeGroupEntity> sizeGroups;
  final int? preSelectedSizeGroupId;
  final List<ProductColorEntity> colors;
  final String productName;
  final String brandName;

  const BulkVariantSheet({
    super.key,
    required this.sizeGroups,
    this.preSelectedSizeGroupId,
    required this.colors,
    this.productName = '',
    this.brandName = '',
  });

  @override
  State<BulkVariantSheet> createState() => _BulkVariantSheetState();
}

class _BulkVariantSheetState extends State<BulkVariantSheet> {
  int? _sizeGroupId;
  Set<String> _selectedSizes = {};
  Set<int> _selectedColorIds = {};
  List<CreateVariantParams>? _preview;

  final _originalPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _sizeGroupId = widget.preSelectedSizeGroupId;
    _initSizes();
    _selectedColorIds =
        widget.colors.where((c) => c.id != null).map((c) => c.id!).toSet();
  }

  void _initSizes() {
    final group = _groupById(_sizeGroupId);
    _selectedSizes = group?.sizes.map((s) => s.name).toSet() ?? {};
  }

  @override
  void dispose() {
    _originalPriceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  SizeGroupEntity? _groupById(int? id) =>
      widget.sizeGroups.where((g) => g.id == id).firstOrNull;

  bool get _canGenerate =>
      _sizeGroupId != null &&
      _selectedSizes.isNotEmpty &&
      _selectedColorIds.isNotEmpty;

  void _onSizeGroupChanged(int? id) => setState(() {
        _sizeGroupId = id;
        _preview = null;
        _initSizes();
      });

  void _toggleSize(String size) => setState(() {
        _selectedSizes.contains(size)
            ? _selectedSizes.remove(size)
            : _selectedSizes.add(size);
        _preview = null;
      });

  void _toggleColor(int colorId) => setState(() {
        _selectedColorIds.contains(colorId)
            ? _selectedColorIds.remove(colorId)
            : _selectedColorIds.add(colorId);
        _preview = null;
      });

  void _generatePreview() {
    if (!_formKey.currentState!.validate()) return;
    final price = double.parse(_originalPriceCtrl.text.trim());
    final stock = int.parse(_stockCtrl.text.trim());
    final group = _groupById(_sizeGroupId);
    final orderedSizes = group != null
        ? group.sizes
            .where((s) => _selectedSizes.contains(s.name))
            .map((s) => s.name)
            .toList()
        : _selectedSizes.toList();

    final drafts = <CreateVariantParams>[];
    for (final colorId in _selectedColorIds) {
      final color = widget.colors.firstWhere((c) => c.id == colorId);
      for (final size in orderedSizes) {
        drafts.add(CreateVariantParams(
          sku: _autoSku(widget.brandName, widget.productName, color.name, size),
          size: size,
          colorId: colorId,
          originalPrice: price,
          stockQuantity: stock,
          status: ProductStatus.active,
        ));
      }
    }
    setState(() => _preview = drafts);
  }

  static String _autoSku(
      String brandName, String productName, String colorName, String size) {
    final brand = _slugCode(brandName, 3);
    final prod = _slugCode(productName, null);
    final color = _slugCode(colorName, 3);
    final colorPart = color.isEmpty ? 'CLR' : color;
    final sizePart = size.toUpperCase();
    final prefix = [brand, prod].where((s) => s.isNotEmpty).join('-');
    return prefix.isEmpty
        ? '$colorPart-$sizePart'
        : '$prefix-$colorPart-$sizePart';
  }

  static String _slugCode(String text, int? maxLen) {
    const vi = {
      'đ': 'd',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ư': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
    };
    final ascii = text
        .toLowerCase()
        .replaceAll(' ', '')
        .split('')
        .map((c) => vi[c] ?? c)
        .join();
    final letters = ascii.replaceAll(RegExp(r'[^a-z]'), '');
    final len = maxLen == null ? letters.length : min(maxLen, letters.length);
    return letters.substring(0, len).toUpperCase();
  }

  void _removePreviewItem(int index) => setState(() {
        final list = List<CreateVariantParams>.from(_preview!);
        list.removeAt(index);
        _preview = list.isEmpty ? null : list;
      });

  Future<void> _editPreviewItem(int index) async {
    final item = _preview![index];
    final result = await showVariantEditDialog(
      context,
      title: 'Chỉnh sửa biến thể',
      initialSku: item.sku,
      initialPrice: item.originalPrice,
      initialStock: item.stockQuantity,
      initialStatus: item.status,
      showStatus: false,
    );
    if (result != null && mounted) {
      setState(() {
        final list = List<CreateVariantParams>.from(_preview!);
        list[index] = CreateVariantParams(
          sku: result.sku ?? item.sku,
          size: item.size,
          colorId: item.colorId,
          originalPrice: result.originalPrice,
          stockQuantity: result.stockQuantity,
          status: item.status,
        );
        _preview = list;
      });
    }
  }

  void _confirm() => Navigator.pop(context, _preview);

  @override
  Widget build(BuildContext context) {
    final group = _groupById(_sizeGroupId);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          _SheetHeader(onClose: () => Navigator.pop(context)),
          Flexible(child: _buildScrollBody(group)),
          _BottomActions(
            onCancel: () => Navigator.pop(context),
            onConfirm: (_preview?.isNotEmpty == true) ? _confirm : null,
            count: _preview?.length ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildScrollBody(SizeGroupEntity? group) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingMd, 0, AppSizes.paddingMd, AppSizes.paddingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SizeGroupDropdown(
                sizeGroups: widget.sizeGroups,
                selectedId: _sizeGroupId,
                onChanged: _onSizeGroupChanged,
              ),
              const SizedBox(height: AppSizes.paddingMd),
              if (group != null) ...[
                _SizeChipsSection(
                  sizes: group.sizes.map((s) => s.name).toList(),
                  selectedSizes: _selectedSizes,
                  onToggle: _toggleSize,
                ),
                const SizedBox(height: AppSizes.paddingMd),
              ],
              _ColorCheckboxSection(
                colors: widget.colors,
                selectedIds: _selectedColorIds,
                onToggle: _toggleColor,
              ),
              const SizedBox(height: AppSizes.paddingMd),
              _DefaultValuesSection(
                originalPriceCtrl: _originalPriceCtrl,
                stockCtrl: _stockCtrl,
              ),
              const SizedBox(height: 12),
              _GenerateButton(
                canGenerate: _canGenerate,
                hasPreview: _preview != null,
                onPressed: _generatePreview,
              ),
              if (_preview != null) ...[
                const SizedBox(height: AppSizes.paddingMd),
                _PreviewSection(
                  preview: _preview!,
                  colors: widget.colors,
                  onRemove: _removePreviewItem,
                  onEdit: _editPreviewItem,
                ),
              ],
            ],
          ),
        ),
      );
}

// ── Shell widgets ─────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingSm),
        child: Row(
          children: [
            const Expanded(
              child: Text('Tạo Nhanh Biến Thể',
                  style: TextStyle(
                      fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700)),
            ),
            IconButton(
                onPressed: onClose, icon: const Icon(Icons.close_rounded)),
          ],
        ),
      );
}

class _GenerateButton extends StatelessWidget {
  final bool canGenerate;
  final bool hasPreview;
  final VoidCallback onPressed;

  const _GenerateButton({
    required this.canGenerate,
    required this.hasPreview,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: canGenerate ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
        ),
        child: Text(hasPreview ? 'Tạo lại tổ hợp' : 'Xem trước tổ hợp'),
      );
}
