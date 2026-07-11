import 'dart:convert';

import 'package:flutter_ecommerce/features/customizer/presentation/models/design_layer.dart';

class ParsedDesignMetadata {
  final List<DesignLayer> layers;
  final bool hasWarning;

  const ParsedDesignMetadata({required this.layers, required this.hasWarning});
}

abstract final class DesignMetadataParser {
  static ParsedDesignMetadata parse(String raw) {
    if (raw.trim().isEmpty) {
      return const ParsedDesignMetadata(layers: [], hasWarning: false);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const ParsedDesignMetadata(layers: [], hasWarning: true);
      }
      final layers = <DesignLayer>[];
      var hasWarning = false;
      for (final entry in decoded) {
        try {
          if (entry is! Map<String, dynamic>) throw const FormatException();
          if (entry['id'] is! String || (entry['id'] as String).trim().isEmpty) {
            throw const FormatException();
          }
          if (entry['type'] is! String || entry['view'] is! String ||
              entry['color'] is! int || entry['fontSize'] is! num ||
              entry['x'] is! num || entry['y'] is! num) {
            throw const FormatException();
          }
          layers.add(DesignLayer.fromJson(entry));
        } catch (_) {
          hasWarning = true;
        }
      }
      return ParsedDesignMetadata(layers: layers, hasWarning: hasWarning);
    } catch (_) {
      return const ParsedDesignMetadata(layers: [], hasWarning: true);
    }
  }
}
