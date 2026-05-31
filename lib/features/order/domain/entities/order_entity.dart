import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, status, totalAmount, createdAt];
}
