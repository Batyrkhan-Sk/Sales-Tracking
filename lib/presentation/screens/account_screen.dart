import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../models/user.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _apiService.getCurrentUser();
      debugPrint('[USER LOADED] name=${user.fullName}, email=${user.email}, role=${user.role}');

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[USER ERROR] $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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

        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_error != null) {
          return Scaffold(
            body: Center(child: Text('Error: $_error')),
          );
        }

        final fullName = _user?.fullName ?? '—';
        final email = _user?.email ?? '—';
        final role = _user?.role ?? '—';

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: isLandscape
                  ? _buildLandscapeLayout(context, fullName, role, email, isSmallScreen, isMediumScreen, isLargeScreen)
                  : _buildPortraitLayout(context, fullName, role, email, isSmallScreen, isMediumScreen, isLargeScreen),
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).colorScheme.surface,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              currentIndex: 3,
              onTap: (index) {
                if (index == 0) Navigator.pushNamed(context, '/explore');
                if (index == 1) Navigator.pushNamed(context, '/qr-code');
                if (index == 2) Navigator.pushNamed(context, '/logs');
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
  }

  Widget _buildPortraitLayout(BuildContext context, String fullName, String role, String email,
      bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
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
                            Text(fullName, style: _nameStyle(context)),
                            const SizedBox(height: 4),
                            Text(role, style: _roleStyle(context)),
                            Text(email, style: _roleStyle(context)),
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

  Widget _buildLandscapeLayout(BuildContext context, String fullName, String role, String email,
      bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) {
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
                Text(fullName, style: _nameStyle(context)),
                const SizedBox(height: 4),
                Text(role, style: _roleStyle(context)),
                Text(email, style: _roleStyle(context)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: isLargeScreen ? 2 : 1,
          child: ListView(
            children: const [
              Divider(),
              MenuItem(icon: Icons.person, text: 'Profile'),
              Divider(),
              MenuItem(icon: Icons.hub_outlined, text: 'Role Management'),
              Divider(),
              MenuItem(icon: Icons.add_box_outlined, text: 'Add Items'),
              Divider(),
              MenuItem(icon: Icons.insert_chart_outlined, text: 'Reports'),
              Divider(),
              MenuItem(icon: Icons.logout, text: 'Logout'),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _nameStyle(BuildContext context) => TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: Theme.of(context).colorScheme.onSurface,
  );

  TextStyle _roleStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
  );
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
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface),
      onTap: onTap,
    );
  }
}