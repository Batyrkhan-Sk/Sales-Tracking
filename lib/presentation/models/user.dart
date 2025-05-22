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

  /// Фабрика для создания из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'], // поддержка и `id`, и `_id`
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  /// Преобразование в JSON — используется при регистрации / обновлении
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    data['fullName'] = fullName;
    data['email'] = email;
    if (password != null) data['password'] = password;
    if (role.isNotEmpty) data['role'] = role;
    return data;
  }

  /// Метод copyWith — удобно обновлять экземпляры
  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email, role: $role)';
  }
}