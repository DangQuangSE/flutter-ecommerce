import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/price_formatter.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/cart/presentation/utils/cart_item_pricing.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/custom_design_spec_entity.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_state.dart';

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
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    context.read<CustomDesignSpecCubit>().loadSpec(widget.customDesignId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomDesignSpecCubit, CustomDesignSpecState>(
      buildWhen: (previous, current) {
        if (previous is! CustomDesignSpecSnapshot ||
            current is! CustomDesignSpecSnapshot) {
          return true;
        }
        final id = widget.customDesignId;
        return previous.specOf(id) != current.specOf(id) ||
            previous.isLoading(id) != current.isLoading(id) ||
            previous.errorOf(id) != current.errorOf(id);
      },
      builder: (context, state) {
        final snapshot = state is CustomDesignSpecSnapshot
            ? state
            : const CustomDesignSpecSnapshot();
        if (snapshot.isLoading(widget.customDesignId)) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSm),
            child: AppLoadingView(size: AppSizes.fontLg),
          );
        }

        return _CustomDesignSpecContent(
          spec: snapshot.specOf(widget.customDesignId),
          fallbackPrintingPrice: widget.fallbackPrintingPrice,
        );
      },
    );
  }
}

class _CustomDesignSpecContent extends StatelessWidget {
  final CustomDesignSpecEntity? spec;
  final double fallbackPrintingPrice;

  const _CustomDesignSpecContent({
    required this.spec,
    required this.fallbackPrintingPrice,
  });

  @override
  Widget build(BuildContext context) {
    final materialText =
        spec?.materialName ?? AppStrings.customDesignSpecUnavailable;
    final textLines = spec?.numTextLines ?? 0;
    final images = spec?.numImages ?? 0;
    final textUnitPrice = spec?.textUnitPrice ?? 0;
    final imageUnitPrice = spec?.imageUnitPrice ?? 0;

    // Per-type pricing: textLayers × textUnitPrice + logoLayers × imageUnitPrice
    // Material base price is NOT added on top.
    final textCost = textLines * textUnitPrice;
    final imageCost = images * imageUnitPrice;
    final printingPrice = resolvedPrintingPriceFromSpec(
      spec: spec,
      fallbackPrintingPrice: fallbackPrintingPrice,
    );

    final materialValueText = materialText.toUpperCase();
    final textValueText = textUnitPrice > 0
        ? '${AppStrings.customDesignSpecTextLines(textLines)} (+${formatPrice(textCost)})'
        : AppStrings.customDesignSpecTextLines(textLines);
    final imageValueText = imageUnitPrice > 0
        ? '${AppStrings.customDesignSpecImages(images)} (+${formatPrice(imageCost)})'
        : AppStrings.customDesignSpecImages(images);

    return Column(
      children: [
        _SpecRow(
          label: AppStrings.customDesignSpecMaterialLabel,
          value: materialValueText,
          isBoldValue: true,
        ),
        SizedBox(height: AppSizes.paddingXs),
        _SpecRow(
          label: AppStrings.customDesignSpecTextLinesLabel,
          value: textValueText,
        ),
        SizedBox(height: AppSizes.paddingXs),
        _SpecRow(
          label: AppStrings.customDesignSpecImagesLabel,
          value: imageValueText,
        ),
        SizedBox(height: AppSizes.paddingXs),
        Container(
          height: 1,
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.15),
        ),
        SizedBox(height: AppSizes.paddingXs),
        _SpecRow(
          label: AppStrings.customDesignSpecTotalLabel,
          value: '+${formatPrice(printingPrice)}',
          isBlueValue: true,
          isBoldValue: true,
        ),
        if (textUnitPrice > 0 || imageUnitPrice > 0) ...[
          SizedBox(height: AppSizes.paddingSm),
          _PricingFormulaHint(
            textUnitPrice: textUnitPrice,
            imageUnitPrice: imageUnitPrice,
          ),
        ],
      ],
    );
  }
}

class _PricingFormulaHint extends StatelessWidget {
  final double textUnitPrice;
  final double imageUnitPrice;

  const _PricingFormulaHint({
    required this.textUnitPrice,
    required this.imageUnitPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F9),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppSizes.fontMd,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSizes.radiusSm),
          Expanded(
            child: Text(
              AppStrings.customDesignSpecPricingFormula(
                formatPrice(textUnitPrice),
                formatPrice(imageUnitPrice),
              ),
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontBadge + 0.5,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;
  final bool isBlueValue;

  const _SpecRow({
    required this.label,
    required this.value,
    this.isBoldValue = false,
    this.isBlueValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSm - 1,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: AppSizes.paddingSm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSm - 1,
              fontWeight: isBoldValue ? FontWeight.w800 : FontWeight.w600,
              color: isBlueValue ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
