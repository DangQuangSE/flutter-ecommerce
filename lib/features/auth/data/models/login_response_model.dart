class LoginResponseModel {
  final String tokenType;
  final String accessToken;
  final int expiresInSeconds;
  final String email;

  const LoginResponseModel({
    required this.tokenType,
    required this.accessToken,
    required this.expiresInSeconds,
    required this.email,
  });

  factory LoginResponseModel.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LoginResponseModel(
      tokenType: data['tokenType'] as String? ?? 'Bearer',
      accessToken: data['accessToken'] as String,
      expiresInSeconds: (data['expiresInSeconds'] as num).toInt(),
      email: data['email'] as String,
    );
  }
}
