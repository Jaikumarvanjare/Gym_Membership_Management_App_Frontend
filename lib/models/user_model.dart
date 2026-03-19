class User {
  final int id;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        email: json['email'] as String,
        role: json['role'] as String,
      );

  bool get isAdmin => role == 'admin';
}