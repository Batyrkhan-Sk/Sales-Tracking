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
      backgroundColor: const Color(0xFFF8F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F2),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage roles',
          style: TextStyle(
            color: Color(0xFF37421F),
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
                color: Color(0xFF37421F),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'email@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      items: roles
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      },
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
                  backgroundColor: const Color(0xFF3D4D1A),
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
                color: Color(0xFF37421F),
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
          const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, color: Color(0xFF37421F)),
            ),
          ),
          if (!isCurrentUser)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black),
              onPressed: onDelete,
            ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: role,
                items: ['Admin', 'Moderator', 'Worker']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: onRoleChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}