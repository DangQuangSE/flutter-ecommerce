class OrderResponseModel {
  final int id;
  final String status;
  final String paymentMethod;

  const OrderResponseModel({
    required this.id,
    required this.status,
    required this.paymentMethod,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'PENDING',
      paymentMethod: json['paymentMethod'] as String? ?? 'BANK_TRANSFER',
    );
  }
}
