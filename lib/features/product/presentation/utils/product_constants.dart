import 'package:flutter/material.dart';

const Map<String, Color> productColorMap = {
  'black': Color(0xFF0D0D0D),
  'white': Color(0xFFF9F9F9),
  'red': Color(0xFFFF3B30),
  'blue': Color(0xFF007AFF),
  'green': Color(0xFF34C759),
  'grey': Color(0xFF8E8E93),
  'gray': Color(0xFF8E8E93),
  'orange': Color(0xFFFF9500),
  'yellow': Color(0xFFFFCC00),
  'navy': Color(0xFF001F5B),
  'volt': Color(0xFFD4FB00),
  'purple': Color(0xFFAF52DE),
  'pink': Color(0xFFFF2D55),
  'brown': Color(0xFF795548),
};

const List<String> productApparelSizeOrder = [
  'XS',
  'S',
  'M',
  'L',
  'XL',
  'XXL',
  '3XL',
];

Color productColorFromName(String name) {
  return productColorMap[name.toLowerCase().trim()] ?? Colors.grey;
}

int compareSizes(String a, String b) {
  final ai = productApparelSizeOrder.indexOf(a.toUpperCase());
  final bi = productApparelSizeOrder.indexOf(b.toUpperCase());
  if (ai != -1 && bi != -1) return ai.compareTo(bi);
  if (ai != -1) return -1;
  if (bi != -1) return 1;
  final an = num.tryParse(a);
  final bn = num.tryParse(b);
  if (an != null && bn != null) return an.compareTo(bn);
  if (an != null) return -1;
  if (bn != null) return 1;
  return a.compareTo(b);
}
