class UserReport {
  final String name;
  final String email;
  final String segment;
  final int numberOfSales;
  final double balance;
  final String? avatarUrl;

  const UserReport({
    required this.name,
    required this.email,
    required this.segment,
    required this.numberOfSales,
    required this.balance,
    this.avatarUrl,
  });
}