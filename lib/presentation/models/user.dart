class User {
  final String? id;
  final String fullName;
  final String email;
  final String? password;
  final String role;

  User({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    this.role = '',
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    data['fullName'] = fullName;
    data['email'] = email;
    if (password != null) data['password'] = password;
    if (role.isNotEmpty) data['role'] = role;
    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}