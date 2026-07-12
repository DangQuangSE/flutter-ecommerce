import 'package:flutter/material.dart';

enum LayerType { text, logo }

enum LayerView { front, back }

class DesignLayer {
  final String id;
  final LayerType type;
  final LayerView view;
  final String text;
  final String font;
  final Color color;
  final double fontSize;
  final double x;
  final double y;
  final String? logoPath;
  final String? logoUrl;
  final double logoSize;

  DesignLayer({
    required this.id,
    required this.type,
    this.view = LayerView.front,
    this.text = '',
    this.font = 'Lexend',
    this.color = const Color(0xFF0058BC),
    this.fontSize = 20.0,
    this.x = 0.0,
    this.y = 0.0,
    this.logoPath,
    this.logoUrl,
    this.logoSize = 80.0,
  });

  /// True when [logoUrl] is a durable, remotely-hosted asset. Legacy layers
  /// only ever have [logoPath] (a local device path that cannot be trusted
  /// off-device), so they are never "available" by this check.
  bool get hasRemoteLogo =>
      logoUrl != null &&
      (logoUrl!.startsWith('http://') || logoUrl!.startsWith('https://'));

  DesignLayer copyWith({
    String? text,
    String? font,
    Color? color,
    double? fontSize,
    double? x,
    double? y,
    String? logoPath,
    String? logoUrl,
    LayerView? view,
    double? logoSize,
  }) {
    return DesignLayer(
      id: id,
      type: type,
      view: view ?? this.view,
      text: text ?? this.text,
      font: font ?? this.font,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      x: x ?? this.x,
      y: y ?? this.y,
      logoPath: logoPath ?? this.logoPath,
      logoUrl: logoUrl ?? this.logoUrl,
      logoSize: logoSize ?? this.logoSize,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'view': view.name,
        'text': text,
        'font': font,
        'color': color.toARGB32(),
        'fontSize': fontSize,
        'x': x,
        'y': y,
        'logoPath': logoPath,
        'logoUrl': logoUrl,
        'logoSize': logoSize,
      };

  factory DesignLayer.fromJson(Map<String, dynamic> json) => DesignLayer(
        id: json['id'] as String,
        type: LayerType.values.byName(json['type'] as String),
        view: json['view'] != null
            ? LayerView.values.byName(json['view'] as String)
            : LayerView.front,
        text: json['text'] as String? ?? '',
        font: json['font'] as String? ?? 'Lexend',
        color: Color(json['color'] as int),
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20.0,
        x: (json['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['y'] as num?)?.toDouble() ?? 0.0,
        logoPath: json['logoPath'] as String?,
        logoUrl: json['logoUrl'] is String ? json['logoUrl'] as String : null,
        logoSize: (json['logoSize'] as num?)?.toDouble() ?? 80.0,
      );
}
