import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Syrymbetov Amir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37421F),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Admin',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tima7700@inbox.ru',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),
            _buildMenuItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {},
            ),
            const Divider(),
            _buildMenuItem(
              icon: Icons.hub_outlined,
              label: 'Manage roles',
              onTap: () {Navigator.pushNamed(context, '/manage-roles');},
            ),
            const Divider(),
            _buildMenuItem(
              icon: Icons.add_box_outlined,
              label: 'Add products',
              onTap: () {},
            ),
            const Divider(),
            _buildMenuItem(
              icon: Icons.logout,
              label: 'Log out',
              onTap: () {},
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF37421F),
        ),
      ),
      trailing: const Icon(Icons.arrow_circle_right_outlined, color: Colors.black),
      onTap: onTap,
    );
  }
}