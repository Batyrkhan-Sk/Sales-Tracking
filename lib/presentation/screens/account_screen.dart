import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../models/user.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double smallScreenThreshold = 360;
        const double mediumScreenThreshold = 600;
        bool isSmallScreen = constraints.maxWidth < smallScreenThreshold;
        bool isMediumScreen = constraints.maxWidth >= smallScreenThreshold &&
            constraints.maxWidth <= mediumScreenThreshold;
        bool isLargeScreen = constraints.maxWidth > mediumScreenThreshold;
        bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        return FutureBuilder<User?>(
          future: ApiService().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  'Error loading user data',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              );
            }

            final user = snapshot.data!;

            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), // Убрал вертикальный отступ
                  child: isLandscape
                      ? _buildLandscapeLayout(context, user, isSmallScreen, isMediumScreen, isLargeScreen)
                      : _buildPortraitLayout(context, user, isSmallScreen, isMediumScreen, isLargeScreen),
                ),
              ),
              bottomNavigationBar: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Theme.of(context).colorScheme.surface,
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  currentIndex: 3,
                  onTap: (index) {
                    if (index == 0) {
                      Navigator.pushNamed(context, '/explore');
                    } else if (index == 1) {
                      Navigator.pushNamed(context, '/qr-code');
                    } else if (index == 2) {
                      Navigator.pushNamed(context, '/logs');
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
          },
        );
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, User user, bool isSmallScreen, bool isMediumScreen,
      bool isLargeScreen) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0), // Сдвиг вниз
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.role,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const Divider(),
                      MenuItem(icon: Icons.person, text: 'Profile', onTap: () => Navigator.pushNamed(context, '/profile')),
                      const Divider(),
                      MenuItem(
                          icon: Icons.hub_outlined,
                          text: 'Role Management',
                          onTap: () => Navigator.pushNamed(context, '/manage-roles')),
                      const Divider(),
                      MenuItem(
                          icon: Icons.add_box_outlined,
                          text: 'Add Items',
                          onTap: () => Navigator.pushNamed(context, '/add-item')),
                      const Divider(),
                      MenuItem(
                          icon: Icons.insert_chart_outlined,
                          text: 'Reports',
                          onTap: () => Navigator.pushNamed(context, '/reports')),
                      const Divider(),
                      MenuItem(
                          icon: Icons.logout,
                          text: 'Logout',
                          onTap: () => Navigator.pushNamed(context, '/signin')),
                      const Divider(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, User user, bool isSmallScreen, bool isMediumScreen,
      bool isLargeScreen) {
    return Row(
      children: [
        Expanded(
          flex: isLargeScreen ? 1 : 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                Text(
                  user.email,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: isLargeScreen ? 2 : 1,
          child: ListView(
            children: [
              const Divider(),
              MenuItem(icon: Icons.person, text: 'Profile', onTap: () => Navigator.pushNamed(context, '/profile')),
              const Divider(),
              MenuItem(
                  icon: Icons.hub_outlined,
                  text: 'Role Management',
                  onTap: () => Navigator.pushNamed(context, '/manage-roles')),
              const Divider(),
              MenuItem(
                  icon: Icons.add_box_outlined,
                  text: 'Add Items',
                  onTap: () => Navigator.pushNamed(context, '/add-item')),
              const Divider(),
              MenuItem(
                  icon: Icons.insert_chart_outlined,
                  text: 'Reports',
                  onTap: () => Navigator.pushNamed(context, '/reports')),
              const Divider(),
              MenuItem(
                  icon: Icons.logout,
                  text: 'Logout',
                  onTap: () => Navigator.pushNamed(context, '/signin')),
              const Divider(),
            ],
          ),
        ),
      ],
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
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), // Уменьшен вертикальный отступ
      visualDensity: VisualDensity.compact, // Компактный вид
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface), // Уменьшен размер иконки
      title: Text(
        text,
        style: const TextStyle(fontSize: 14), // Уменьшен размер текста
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface), // Уменьшен размер стрелки
      onTap: onTap,
    );
  }
}