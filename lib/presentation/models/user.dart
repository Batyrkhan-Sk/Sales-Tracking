// lib/models/user.dart
class User {
  final String? id;
  final String fullName;
  final String email;
  final String? password;

  User({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
  });
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    data['fullName'] = fullName;
    data['email'] = email;
    if (password != null) data['password'] = password;
    return data;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
    );
  }

}