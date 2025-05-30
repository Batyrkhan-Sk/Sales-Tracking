import 'package:flutter/material.dart';
import 'package:sales_tracking/services/api_service.dart';

class ManageRolesScreen extends StatefulWidget {
  const ManageRolesScreen({super.key});

  @override
  State<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends State<ManageRolesScreen> {
  final List<String> roles = const ['admin', 'moderator', 'manager'];
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> members = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedUsers = await _apiService.getAllUsers();
      setState(() {
        members = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  Future<void> _updateUserRole(int index, String userId, String newRole) async {
    print('_updateUserRole called: index=$index, userId=$userId, newRole=$newRole');
    print('Current members[index] before update: ${members[index]}');

    // Сохраняем старую роль для отката в случае ошибки
    final oldRole = members[index]['role'];

    // Сразу обновляем UI для лучшего UX
    setState(() {
      members[index]['role'] = newRole;
    });

    print('Updated members[index]: ${members[index]}');

    try {
      print('Sending API request...');
      await _apiService.updateUserRole(userId: userId, role: newRole);
      print('API request successful');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role updated successfully')),
        );
      }
    } catch (e) {
      print('API request failed: $e');
      // Если запрос не удался, возвращаем старое значение
      setState(() {
        members[index]['role'] = oldRole;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F8F2);
    final appBarColor = isDarkMode ? const Color(0xFF222222) : const Color(0xFFF8F8F2);
    final textColor = isDarkMode ? const Color(0xFFB8C7A1) : const Color(0xFF37421F);
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage roles',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(
        child: Text('No users found'),
      )
          : RefreshIndicator(
        onRefresh: _fetchUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final user = members[index];

            // Отладочная информация для структуры данных
            print('User $index data: $user');
            print('Available keys: ${user.keys.toList()}');

            // Попробуем разные варианты названий полей
            final userId = user['id']?.toString() ??
                user['userId']?.toString() ??
                user['_id']?.toString() ??
                user['user_id']?.toString();

            final fullName = user['fullName'] ?? user['full_name'] ?? user['name'];
            final email = user['email'];
            final currentRole = user['role'];

            print('Extracted: userId=$userId, fullName=$fullName, email=$email, role=$currentRole');

            // Проверяем, что у нас есть необходимые данные
            if (userId == null) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(fullName ?? email ?? 'Unknown User'),
                  subtitle: Text('Error: No user ID found'),
                  trailing: Icon(Icons.error, color: Colors.red),
                ),
              );
            }

            // Отладочная информация
            print('User $index: currentRole = "$currentRole", type: ${currentRole.runtimeType}');
            print('Available roles: $roles');
            print('Role in roles list: ${roles.contains(currentRole)}');

            // Убеждаемся, что роль существует в списке, иначе используем первую доступную
            final validRole = roles.contains(currentRole) ? currentRole : roles.first;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(fullName ?? email ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email ?? ''),
                    Text('Current role: $currentRole', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: DropdownButton<String>(
                  value: validRole, // Используем проверенную роль
                  onChanged: (newRole) {
                    print('Dropdown changed: from "$currentRole" to "$newRole"');
                    if (newRole != null && newRole != currentRole) {
                      print('Calling _updateUserRole with index: $index, userId: $userId, newRole: $newRole');
                      // Проверяем, что userId не null перед вызовом
                      if (userId != null) {
                        _updateUserRole(index, userId, newRole);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: User ID not found')),
                        );
                      }
                    }
                  },
                  items: roles
                      .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r),
                  ))
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}