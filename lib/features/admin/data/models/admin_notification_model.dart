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
      createdAt: json['createdAt'] is List 
          ? '${json['createdAt'][0]}-${json['createdAt'][1].toString().padLeft(2, '0')}-${json['createdAt'][2].toString().padLeft(2, '0')}T${json['createdAt'].length > 3 ? json['createdAt'][3].toString().padLeft(2, '0') : '00'}:${json['createdAt'].length > 4 ? json['createdAt'][4].toString().padLeft(2, '0') : '00'}'
          : json['createdAt']?.toString() ?? '',
    );
  }
}
