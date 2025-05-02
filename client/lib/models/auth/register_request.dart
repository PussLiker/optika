class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? lastName;
  final String role; // добавляем роль

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.lastName,
    required this.role, // добавляем роль
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'lastName': lastName,
      'role': role, // добавляем роль
    };
  }
}
