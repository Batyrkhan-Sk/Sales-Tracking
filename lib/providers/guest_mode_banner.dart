import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../presentation/screens/sign_in_screen.dart';

class GuestModeBanner extends StatelessWidget {
  final bool showDismiss;

  const GuestModeBanner({
    super.key,
    this.showDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    final guestModeProvider = Provider.of<GuestModeProvider>(context);

    if (!guestModeProvider.showGuestBanner) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700),
      ),
      width: double.infinity,
      child: Row(
        children: [
          Icon(Icons.person_outline, color: Colors.amber.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Sign in to access all features',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
          if (showDismiss)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                guestModeProvider.dismissBanner();
              },
              color: Colors.amber.shade900,
            ),
        ],
      ),
    );
  }
}