class AdminNotificationModel {
  final int orderId;
  final String customerName;
  final double totalAmount;
  final String createdAt;
  final String message;

  AdminNotificationModel({
    required this.orderId,
    required this.customerName,
    required this.totalAmount,
    required this.createdAt,
    required this.message,
  });

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationModel(
      orderId: json['orderId'],
      customerName: json['customerName'] ?? 'Unknown',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
