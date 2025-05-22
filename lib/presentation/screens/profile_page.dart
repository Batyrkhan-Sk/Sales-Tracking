import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../models/user.dart';
import 'sign_in_screen.dart';
import '../../providers/app_providers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _apiService.isLoggedIn(),
      builder: (context, loginSnapshot) {
        if (loginSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  onPressed: () => _logout(context),
                  child: Text(
                    AppLocalizations.of(context)!.logout,
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
              child: isGuestMode
                  ? _buildGuestModeContent(context)
                  : _buildLoggedInContent(context),
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
          child: Icon(Icons.person_outline, size: 60, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.guestUser,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      title: Text(AppLocalizations.of(context)!.darkMode),
                      trailing: Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                    );
                  },
                ),
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return ListTile(
                      title: Text(AppLocalizations.of(context)!.language),
                      trailing: DropdownButton<Locale>(
                        value: languageProvider.locale,
                        items: [
                          DropdownMenuItem(
                            value: const Locale('en', 'US'),
                            child: Text(AppLocalizations.of(context)!.english),
                          ),
                          DropdownMenuItem(
                            value: const Locale('ru', 'RU'),
                            child: Text(AppLocalizations.of(context)!.russian),
                          ),
                        ],
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            languageProvider.setLocale(newLocale);
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
                  child: Text(AppLocalizations.of(context)!.signIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInContent(BuildContext context) {
    return FutureBuilder<User?>(
      future: _apiService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.unableToLoadUserData),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                child: Text(AppLocalizations.of(context)!.returnToLogin),
              ),
            ],
          );
        }

        final user = snapshot.data!;
        final localizations = AppLocalizations.of(context)!;

        _nameController.text = user.fullName;
        final email = user.email;

        return Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Text(user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(localizations.administratorRole, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(labelText: localizations.name, border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: email),
                      enabled: false,
                      decoration: InputDecoration(labelText: localizations.email, border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    if (_isEditing)
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: localizations.password, border: const OutlineInputBorder()),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(_isEditing ? Icons.close : Icons.edit),
                          onPressed: () => setState(() => _isEditing = !_isEditing),
                          label: Text(_isEditing ? localizations.cancel : localizations.edit),
                        ),
                        if (_isEditing)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              try {
                                final newName = _nameController.text.trim();
                                final newPassword = _passwordController.text.trim();

                                await _apiService.updateProfile(
                                  fullName: newName != user.fullName ? newName : null,
                                  password: newPassword.isNotEmpty ? newPassword : null,
                                );

                                setState(() => _isEditing = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(localizations.profileUpdated)),
                                );
                              } catch (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(localizations.updateFailed)),
                                );
                              }
                            },
                            label: Text(localizations.save),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return ListTile(
                          title: Text(localizations.darkMode),
                          trailing: Switch(
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                        );
                      },
                    ),
                    Consumer<LanguageProvider>(
                      builder: (context, languageProvider, _) {
                        return ListTile(
                          title: Text(localizations.language),
                          trailing: DropdownButton<Locale>(
                            value: languageProvider.locale,
                            items: [
                              DropdownMenuItem(
                                value: const Locale('en', 'US'),
                                child: Text(localizations.english),
                              ),
                              DropdownMenuItem(
                                value: const Locale('ru', 'RU'),
                                child: Text(localizations.russian),
                              ),
                            ],
                            onChanged: (newLocale) {
                              if (newLocale != null) {
                                languageProvider.setLocale(newLocale);
                              }
                            },
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
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _apiService.logout();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }
}