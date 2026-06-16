import 'package:flutter/material.dart';

abstract final class OrderStatusLabel {
  static const List<String> allStatuses = [
    'PENDING',
    'CONFIRMED',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED',
    'RETURN_REQUESTED',
    'RETURNED',
    'REFUNDED',
  ];

  static String vi(String status) => switch (status.toUpperCase()) {
        'PENDING' => 'Chờ xác nhận',
        'CONFIRMED' => 'Đã xác nhận',
        'PROCESSING' => 'Đang xử lý',
        'SHIPPED' => 'Đang giao',
        'DELIVERED' => 'Đã giao',
        'CANCELLED' => 'Đã hủy',
        'RETURN_REQUESTED' => 'Yêu cầu trả hàng',
        'RETURNED' => 'Đã trả hàng',
        'REFUNDED' => 'Đã hoàn tiền',
        _ => status,
      };

  static (Color background, Color foreground) badgeColors(String status) {
    return switch (status.toUpperCase()) {
      'PENDING' || 'CONFIRMED' => (
          const Color(0xFFF3F4F6),
          const Color(0xFF4B5563),
        ),
      'PROCESSING' || 'SHIPPED' => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
        ),
      'DELIVERED' => (
          const Color(0xFFD1FAE5),
          const Color(0xFF059669),
        ),
      'CANCELLED' || 'RETURNED' || 'REFUNDED' => (
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626),
        ),
      'RETURN_REQUESTED' => (
          const Color(0xFFEDE9FE),
          const Color(0xFF7C3AED),
        ),
      _ => (
          const Color(0xFFF3F4F6),
          const Color(0xFF4B5563),
        ),
    };
  }

  static String paymentMethodVi(String method) => switch (method.toUpperCase()) {
        'COD' => 'Thanh toán khi nhận hàng',
        'BANK_TRANSFER' => 'VNPay',
        'CREDIT_CARD' => 'Thẻ tín dụng',
        _ => method,
      };
}
