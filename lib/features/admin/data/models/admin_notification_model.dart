class AdminNotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final int orderId;
  final String customerName;
  final String createdAt;

  AdminNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.orderId,
    required this.customerName,
    required this.createdAt,
  });

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      orderId: json['orderId'] ?? json['relatedId'] ?? 0,
      customerName: json['customerName'] ?? 'Unknown',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
