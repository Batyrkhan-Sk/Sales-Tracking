import 'package:flutter/material.dart';

class ManageRolesScreen extends StatelessWidget {
  const ManageRolesScreen({super.key});

  final List<String> roles = const ['Admin', 'Moderator', 'Worker'];

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
                      value: roles[0],
                      items: roles
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                          .toList(),
                      onChanged: (value) {},
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
                onPressed: () {},
                child: const Text(
                  'Send invite',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white
                  ),
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
            _buildMemberItem(
              context,
              name: 'Amir Syrymbetov (you)',
              role: 'Admin',
              isCurrentUser: true,
            ),
            _buildMemberItem(
              context,
              name: 'Temirkhanov Tamerlan',
              role: 'Worker',
              isCurrentUser: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, size: 28),
            Icon(Icons.qr_code, size: 28),
            Icon(Icons.edit_note, size: 28),
            Icon(Icons.menu, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context,
      {required String name, required String role, required bool isCurrentUser}) {
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
              onPressed: () {},
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
                onChanged: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}