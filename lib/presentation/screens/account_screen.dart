import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Amir Syrimbetov',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Administrator', style: TextStyle(color: Colors.black54)),
                      Text('Tima7700@inbox.ru', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    const Divider(),
                    MenuItem(
                      icon: Icons.person,
                      text: 'Profile',
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    const Divider(),
                    MenuItem(
                      icon: Icons.hub_outlined,
                      text: 'Role Management',
                      onTap: () => Navigator.pushNamed(context, '/manage-roles'),
                    ),
                    const Divider(),
                    MenuItem(
                      icon: Icons.add_box_outlined,
                      text: 'Add Items',
                      onTap: () => Navigator.pushNamed(context, '/add-item'), // <-- Navigate to the named route
                    ),
                    const Divider(),
                    MenuItem(
                      icon: Icons.insert_chart_outlined,
                      text: 'Reports',
                      onTap: () => Navigator.pushNamed(context, '/reports'),
                    ),
                    const Divider(),
                    MenuItem(
                      icon: Icons.logout,
                      text: 'Logout',
                      onTap: () => Navigator.pushNamed(context, '/signin'),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black54,
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamed(context, '/explore');
            } else if (index == 1) {
              Navigator.pushNamed(context, '/qr-code');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/reports');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black),
      onTap: onTap,
    );
  }
}