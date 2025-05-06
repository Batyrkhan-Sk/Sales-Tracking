import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../models/user.dart';
import 'sign_in_screen.dart';
import '../../providers/app_providers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return FutureBuilder<bool>(
      future: apiService.isLoggedIn(),
      builder: (context, loginSnapshot) {
        if (loginSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = loginSnapshot.data ?? false;
        final isGuestMode = !isLoggedIn;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!isGuestMode)
                TextButton(
                  onPressed: () async {
                    try {
                      await apiService.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: $e')),
                      );
                    }
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isGuestMode)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Guest Mode: Limited access',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to access all features including profile settings and personalization.',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignInScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ),

                  if (isGuestMode)
                    _buildGuestModeContent(context)
                  else
                    _buildLoggedInContent(context, apiService),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestModeContent(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Icon(
            Icons.person_outline,
            size: 60,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Guest User',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),

        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      trailing: Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                      ),
                    );
                  },
                ),
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return ListTile(
                      title: Text(
                        'Language',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      trailing: DropdownButton<Locale>(
                        value: languageProvider.locale,
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en', 'US'),
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ru', 'RU'),
                            child: Text('Russian'),
                          ),
                        ],
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            languageProvider.setLocale(newLocale);
                          }
                        },
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInContent(BuildContext context, ApiService apiService) {
    return FutureBuilder<User?>(
      future: apiService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Unable to load user data',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                child: const Text('Return to Login'),
              ),
            ],
          );
        }

        final user = snapshot.data!;
        return Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${user.role} user',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return ListTile(
                          title: Text(
                            'Dark Mode',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          trailing: Switch(
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                          ),
                        );
                      },
                    ),
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        return ListTile(
                          title: Text(
                            'Language',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          trailing: DropdownButton<Locale>(
                            value: languageProvider.locale,
                            items: const [
                              DropdownMenuItem(
                                value: Locale('en', 'US'),
                                child: Text('English'),
                              ),
                              DropdownMenuItem(
                                value: Locale('ru', 'RU'),
                                child: Text('Russian'),
                              ),
                            ],
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null) {
                                languageProvider.setLocale(newLocale);
                              }
                            },
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            dropdownColor: Theme.of(context).colorScheme.surface,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      enabled: false,
                      controller: TextEditingController(text: user.fullName),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: false,
                      controller: TextEditingController(text: user.email),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      enabled: false,
                      controller: TextEditingController(text: ''),
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        hintText: 'Enter...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}