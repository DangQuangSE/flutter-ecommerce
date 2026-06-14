import 'package:flutter/material.dart';

enum LayerType { text, logo }

class DesignLayer {
  final String id;
  final LayerType type;
  final String text;
  final String font;
  final Color color;
  final double fontSize;
  final double x;
  final double y;
  final String? logoPath;

  DesignLayer({
    required this.id,
    required this.type,
    this.text = '',
    this.font = 'Lexend',
    this.color = const Color(0xFF0058BC),
    this.fontSize = 20.0,
    this.x = 0.0,
    this.y = 0.0,
    this.logoPath,
  });

  DesignLayer copyWith({
    String? text,
    String? font,
    Color? color,
    double? fontSize,
    double? x,
    double? y,
    String? logoPath,
  }) {
    return DesignLayer(
      id: id,
      type: type,
      text: text ?? this.text,
      font: font ?? this.font,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      x: x ?? this.x,
      y: y ?? this.y,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'font': font,
        'color': color.toARGB32(),
        'fontSize': fontSize,
        'x': x,
        'y': y,
        'logoPath': logoPath,
      };

  factory DesignLayer.fromJson(Map<String, dynamic> json) => DesignLayer(
        id: json['id'] as String,
        type: LayerType.values.byName(json['type'] as String),
        text: json['text'] as String? ?? '',
        font: json['font'] as String? ?? 'Lexend',
        color: Color(json['color'] as int),
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20.0,
        x: (json['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['y'] as num?)?.toDouble() ?? 0.0,
        logoPath: json['logoPath'] as String?,
      );
}
