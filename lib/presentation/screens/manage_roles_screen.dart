import 'package:flutter/material.dart';

class ManageRolesScreen extends StatefulWidget {
  const ManageRolesScreen({super.key});

  @override
  State<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends State<ManageRolesScreen> {
  final List<String> roles = const ['Admin', 'Moderator', 'Worker'];
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'Admin';
  List<Map<String, dynamic>> members = [
    {'name': 'Amir Syrymbetov (you)', 'role': 'Admin', 'isCurrentUser': true},
    {'name': 'Temirkhanov Tamerlan', 'role': 'Worker', 'isCurrentUser': false},
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage roles',
          style: TextStyle(
            color: Color(0xFFB8C7A1),
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
            const Text(
              'Share',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFB8C7A1),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'email@example.com',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF444444)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF444444)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF6A8B39)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      fillColor: const Color(0xFF2A2A2A),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    border: Border.all(color: const Color(0xFF444444)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      dropdownColor: const Color(0xFF2A2A2A),
                      items: roles
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role, style: const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      },
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                  backgroundColor: const Color(0xFF6A8B39),
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
            const Text(
              'Members of storage app',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFB8C7A1),
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
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context,
      {required String name,
        required String role,
        required bool isCurrentUser,
        VoidCallback? onDelete,
        ValueChanged<String?>? onRoleChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF444444),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          if (!isCurrentUser)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: onDelete,
            ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              border: Border.all(color: const Color(0xFF444444)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: role,
                dropdownColor: const Color(0xFF2A2A2A),
                items: ['Admin', 'Moderator', 'Worker']
                    .map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r, style: const TextStyle(color: Colors.white)),
                ))
                    .toList(),
                onChanged: onRoleChanged,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}