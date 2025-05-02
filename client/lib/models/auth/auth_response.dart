class AuthResponse {
  final String token;
  final String email;
  final String role;
  final int userId;

  AuthResponse({
    required this.token,
    required this.email,
    required this.role,
    required this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      email: json['email'],
      role: json['role'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'email': email,
    'role': role,
    'userId': userId,
  };
}
