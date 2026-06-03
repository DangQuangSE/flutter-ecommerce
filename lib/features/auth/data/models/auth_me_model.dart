class AuthMeModel {
  final String email;
  final String role;
  final String tier;
  final num totalSpending;

  const AuthMeModel({
    required this.email,
    required this.role,
    required this.tier,
    required this.totalSpending,
  });

  factory AuthMeModel.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthMeModel(
      email: data['email'] as String,
      role: data['role'] as String,
      tier: data['tier'] as String,
      totalSpending: data['totalSpending'] as num? ?? 0,
    );
  }
}
