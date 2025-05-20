import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/connectivity_service.dart';

class SyncButton extends StatelessWidget {
  final VoidCallback onSync;

  const SyncButton({super.key, required this.onSync});

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityService>(context).isOnline;

    return ElevatedButton.icon(
      onPressed: isOnline ? onSync : null,
      icon: const Icon(Icons.sync),
      label: Text(isOnline ? 'Sync' : 'Offline - Sync Disabled'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOnline ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
      ),
    );
  }
}
