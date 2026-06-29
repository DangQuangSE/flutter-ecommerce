import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/utils/price_formatter.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/custom_design_spec_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_custom_design_spec_usecase.dart';

class CustomDesignSpecCard extends StatefulWidget {
  final int customDesignId;
  final double fallbackPrintingPrice;

  const CustomDesignSpecCard({
    super.key,
    required this.customDesignId,
    required this.fallbackPrintingPrice,
  });

  @override
  State<CustomDesignSpecCard> createState() => _CustomDesignSpecCardState();
}

class _CustomDesignSpecCardState extends State<CustomDesignSpecCard> {
  bool _isLoading = true;
  String? _materialName;
  int _numTextLines = 0;
  int _numImages = 0;
  double _totalPrintingPrice = 0.0;
  double _materialBasePrice = 0.0;
  double _textUnitPrice = 0.0;
  double _imageUnitPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDesignDetails();
  }

  Future<void> _loadDesignDetails() async {
    try {
      final result =
          await sl<GetCustomDesignSpecUseCase>()(widget.customDesignId);
      if (result is! Success<CustomDesignSpecEntity>) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final spec = result.data;

      if (mounted) {
        setState(() {
          _materialName = spec.materialName;
          _numTextLines = spec.numTextLines;
          _numImages = spec.numImages;
          _totalPrintingPrice = spec.totalPrintingPrice;
          _materialBasePrice = spec.materialBasePrice;
          _textUnitPrice = spec.textUnitPrice;
          _imageUnitPrice = spec.imageUnitPrice;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom design details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0058BC))),
          ),
        ),
      );
    }

    final materialText = _materialName ?? 'N/A';
    final textLines = _numTextLines;
    final images = _numImages;
    final printingPrice = _totalPrintingPrice > 0
        ? _totalPrintingPrice
        : widget.fallbackPrintingPrice;

    final textCost = textLines * _textUnitPrice;
    final imageCost = images * _imageUnitPrice;

    final materialValueText = _materialBasePrice > 0
        ? '${materialText.toUpperCase()} (+${formatPrice(_materialBasePrice)})'
        : materialText.toUpperCase();
    final textValueText = _textUnitPrice > 0
        ? '$textLines lớp (+${formatPrice(textCost)})'
        : '$textLines lớp';
    final imageValueText = _imageUnitPrice > 0
        ? '$images ảnh (+${formatPrice(imageCost)})'
        : '$images ảnh';

    return Column(
      children: [
        _buildSpecRow('Chất liệu tuyển chọn:', materialValueText,
            isBoldValue: true),
        const SizedBox(height: 4),
        _buildSpecRow('Số lớp chữ in thêm:', textValueText),
        const SizedBox(height: 4),
        _buildSpecRow('Số logo tải lên:', imageValueText),
        const SizedBox(height: 4),
        Container(
            height: 1, color: const Color(0xFFC1C6D7).withValues(alpha: 0.15)),
        const SizedBox(height: 4),
        _buildSpecRow(
          'Tổng cộng chi phí in:',
          '+${formatPrice(printingPrice)}',
          isBlueValue: true,
          isBoldValue: true,
        ),
        if (_textUnitPrice > 0 && _imageUnitPrice > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 12, color: Color(0xFF0058BC)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Công thức tính giá in ấn: Giá phôi in + (Số lớp chữ x ${formatPrice(_textUnitPrice)}/lớp) + (Số logo x ${formatPrice(_imageUnitPrice)}/ảnh)',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0058BC),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecRow(String label, String value,
      {bool isBoldValue = false, bool isBlueValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
              color:
                  isBlueValue ? const Color(0xFF0058BC) : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
