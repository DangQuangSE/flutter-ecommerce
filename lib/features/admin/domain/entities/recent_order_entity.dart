import 'package:equatable/equatable.dart';

class RecentOrderEntity extends Equatable {
  final String id;
  final String orderCode;
  final String productName;
  final String rawStatus;
  final String status;
  final double price;
  final DateTime date;

  const RecentOrderEntity({
    required this.id,
    required this.orderCode,
    required this.productName,
    required this.rawStatus,
    required this.status,
    required this.price,
    required this.date,
  });

  @override
  List<Object?> get props =>
      [id, orderCode, productName, rawStatus, status, price, date];
}
