import 'package:hive/hive.dart';

part 'auth_data.g.dart'; // не забудь сгенерировать

@HiveType(typeId: 0)
class AuthData extends HiveObject {
  @HiveField(0)
  final String token;

  @HiveField(1)
  final String pin;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String fullName;

  @HiveField(4)
  final String email;

  AuthData({
    required this.token,
    required this.pin,
    required this.userId,
    required this.fullName,
    required this.email,
  });
  AuthData copyWith({
    String? token,
    String? userId,
    String? fullName,
    String? email,
    String? pin,
  }) {
    return AuthData(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      pin: pin ?? this.pin,
    );
  }
}
