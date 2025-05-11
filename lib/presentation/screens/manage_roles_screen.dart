import 'package:flutter/material.dart';

class ManageRolesScreen extends StatefulWidget {
  const ManageRolesScreen({super.key});

  @override
  State<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends State<ManageRolesScreen> {
  final List<String> roles = const ['Admin', 'Moderator', 'Manager'];
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'Admin';
  List<Map<String, dynamic>> members = [
    {'name': 'Amir Syrymbetov (you)', 'role': 'Admin', 'isCurrentUser': true},
    {'name': 'Temirkhanov Tamerlan', 'role': 'Manager', 'isCurrentUser': false},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite sent!')),
    );
  }

  void _deleteMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  void _updateRole(int index, String? newRole) {
    if (newRole != null) {
      setState(() {
        members[index]['role'] = newRole;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F8F2);
    final appBarColor = isDarkMode ? const Color(0xFF222222) : const Color(0xFFF8F8F2);
    final textColor = isDarkMode ? const Color(0xFFB8C7A1) : const Color(0xFF37421F);
    final buttonColor = isDarkMode ? const Color(0xFF6A8B39) : const Color(0xFF3D4D1A);
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? const Color(0xFF444444) : Colors.black38;
    final inputFillColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final inputTextColor = isDarkMode ? Colors.white : Colors.black;
    final avatarColor = isDarkMode ? const Color(0xFF444444) : Colors.grey;

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share',
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: inputTextColor),
                    decoration: InputDecoration(
                      hintText: 'email@example.com',
                      hintStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: buttonColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      fillColor: inputFillColor,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      dropdownColor: inputFillColor,
                      items: roles
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role, style: TextStyle(color: inputTextColor)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      },
                      icon: Icon(Icons.arrow_drop_down, color: iconColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _sendInvite,
                child: const Text(
                  'Send invite',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Members of storage app',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            ...members.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return _buildMemberItem(
                context,
                name: member['name'],
                role: member['role'],
                isCurrentUser: member['isCurrentUser'],
                onDelete: () => _deleteMember(index),
                onRoleChanged: (newRole) => _updateRole(index, newRole),
                isDarkMode: isDarkMode,
                textColor: inputTextColor,
                borderColor: borderColor,
                inputFillColor: inputFillColor,
                iconColor: iconColor,
                avatarColor: avatarColor,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(
      BuildContext context, {
        required String name,
        required String role,
        required bool isCurrentUser,
        required bool isDarkMode,
        required Color textColor,
        required Color borderColor,
        required Color inputFillColor,
        required Color iconColor,
        required Color avatarColor,
        VoidCallback? onDelete,
        ValueChanged<String?>? onRoleChanged,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: avatarColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
          if (!isCurrentUser)
            IconButton(
              icon: Icon(Icons.delete_outline, color: isDarkMode ? Colors.white70 : Colors.black87),
              onPressed: onDelete,
            ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: inputFillColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: role,
                dropdownColor: inputFillColor,
                items: ['Admin', 'Moderator', 'Manager']
                    .map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r, style: TextStyle(color: textColor)),
                ))
                    .toList(),
                onChanged: onRoleChanged,
                icon: Icon(Icons.arrow_drop_down, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}