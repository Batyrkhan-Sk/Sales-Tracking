import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connectivity_service.dart';

/// Helper widget to consume connectivity status using your existing ConnectivityService
class ConnectivityConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, bool isOnline) builder;

  const ConnectivityConsumer({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        return builder(context, connectivity.isOnline);
      },
    );
  }
}

/// Widget that shows different content based on connectivity status
class ConnectivityAware extends StatelessWidget {
  final Widget onlineChild;
  final Widget? offlineChild;
  final String? offlineMessage;

  const ConnectivityAware({
    super.key,
    required this.onlineChild,
    this.offlineChild,
    this.offlineMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ConnectivityConsumer(
      builder: (context, isOnline) {
        if (isOnline) {
          return onlineChild;
        }

        if (offlineChild != null) {
          return offlineChild!;
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                offlineMessage ?? 'You\'re offline',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Please check your internet connection',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}