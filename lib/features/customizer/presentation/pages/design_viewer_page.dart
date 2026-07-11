import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/design_viewer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/design_viewer_state.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';

class DesignViewerPage extends StatelessWidget {
  final int designId;
  final DesignViewerRole role;

  const DesignViewerPage({super.key, required this.designId, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.designViewerTitle)),
      body: BlocBuilder<DesignViewerCubit, DesignViewerState>(
        builder: (context, state) => switch (state) {
          DesignViewerInitial() || DesignViewerLoading() =>
            const Center(child: CircularProgressIndicator()),
          DesignViewerFailure(:final message) => Center(child: Text(message)),
          DesignViewerLoaded() => _ViewerContent(state: state, role: role),
        },
      ),
    );
  }
}

class _ViewerContent extends StatelessWidget {
  final DesignViewerLoaded state;
  final DesignViewerRole role;
  const _ViewerContent({required this.state, required this.role});

  @override
  Widget build(BuildContext context) {
    final isFront = state.side == LayerView.front;
    final preview = isFront
        ? state.design.designImageUrl
        : state.design.backDesignImageUrl;
    final warning = isFront ? state.frontWarning : state.backWarning;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<LayerView>(
          segments: [
            ButtonSegment(value: LayerView.front, label: const Text(AppStrings.designViewerFront), enabled: state.design.designImageUrl?.isNotEmpty == true),
            ButtonSegment(value: LayerView.back, label: const Text(AppStrings.designViewerBack), enabled: state.design.backDesignImageUrl?.isNotEmpty == true),
          ],
          selected: {state.side},
          onSelectionChanged: (value) => context.read<DesignViewerCubit>().selectSide(value.first),
        ),
        const SizedBox(height: 16),
        _Preview(url: preview),
        if (warning) const Padding(padding: EdgeInsets.only(top: 12), child: Text(AppStrings.designViewerLimited)),
        if (role == DesignViewerRole.admin && preview != null && preview.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _openPreview(context, preview),
              icon: const Icon(Icons.open_in_new),
              label: const Text(AppStrings.designViewerOpenPreview),
            ),
          ),
        const SizedBox(height: 12),
        Text(AppStrings.designViewerLayers, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (state.visibleLayers.isEmpty)
          const Text(AppStrings.designViewerNoLayers)
        else
          ...state.visibleLayers.map((layer) => _LayerTile(layer: layer, selected: state.selectedLayerId == layer.id)),
        if (state.selectedLayer != null)
          _SelectedLayerDetails(layer: state.selectedLayer!),
        const SizedBox(height: 16),
        Text('${AppStrings.designViewerMaterial}: ${state.design.printingMaterialName}'),
        Text('${AppStrings.designViewerPrintingPrice}: ${state.design.totalPrintingPrice.toStringAsFixed(0)}đ'),
      ],
    );
  }

  Future<void> _openPreview(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) AppSnackBar.show(context, message: AppStrings.designViewerOpenFailed, type: AppSnackBarType.error);
    }
  }
}

class _SelectedLayerDetails extends StatelessWidget {
  final DesignLayer layer;
  const _SelectedLayerDetails({required this.layer});

  @override
  Widget build(BuildContext context) {
    final side = layer.view == LayerView.front
        ? AppStrings.designViewerFront
        : AppStrings.designViewerBack;
    final asset = layer.logoPath?.isNotEmpty == true
        ? AppStrings.designViewerAssetAvailable
        : AppStrings.designViewerAssetUnavailable;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(side, style: Theme.of(context).textTheme.titleSmall),
            if (layer.type == LayerType.text) ...[
              Text(layer.text),
              Text('${layer.font} · ${layer.fontSize.toStringAsFixed(0)}px'),
              Text('#${layer.color.toARGB32().toRadixString(16).padLeft(8, '0')}'),
            ] else
              Text(asset),
            Text('X: ${layer.x.toStringAsFixed(1)} · Y: ${layer.y.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final String? url;
  const _Preview({required this.url});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.42,
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: url == null || url!.isEmpty
              ? const Icon(Icons.image_not_supported_outlined, size: 64)
              : CachedNetworkImage(imageUrl: url!, fit: BoxFit.contain, errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 64)),
        ),
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  final DesignLayer layer;
  final bool selected;
  const _LayerTile({required this.layer, required this.selected});
  @override
  Widget build(BuildContext context) {
    final detail = layer.type == LayerType.text
        ? '${layer.text} · ${layer.font} · ${layer.fontSize.toStringAsFixed(0)}px'
        : (layer.logoPath?.isNotEmpty == true ? layer.logoPath! : AppStrings.designViewerLimited);
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(layer.type == LayerType.text ? Icons.text_fields : Icons.image_outlined),
        title: Text(layer.type == LayerType.text ? layer.text : 'Logo'),
        subtitle: Text('$detail\nX: ${layer.x.toStringAsFixed(1)} · Y: ${layer.y.toStringAsFixed(1)}'),
        isThreeLine: true,
        onTap: () => context.read<DesignViewerCubit>().selectLayer(layer.id),
      ),
    );
  }
}
