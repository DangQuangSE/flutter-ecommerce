String formatPrice(double price) {
  final formatStr = price.toInt().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < formatStr.length; i++) {
    buffer.write(formatStr[i]);
    if ((formatStr.length - 1 - i) % 3 == 0 && i != formatStr.length - 1) {
      buffer.write('.');
    }
  }
  return '${buffer.toString()}đ';
}
