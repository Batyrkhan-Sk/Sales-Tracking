import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Add Hive
import 'presentation/screens/explore_screen.dart';
import 'presentation/screens/sign_in_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/account_screen.dart';
import 'presentation/screens/manage_roles_screen.dart';
import 'presentation/screens/warehouse_details_screen.dart';
import 'presentation/screens/qr_code_screen.dart';
import 'presentation/screens/logs_screen.dart';
import 'presentation/screens/profile_page.dart';
import 'presentation/models/warehouse.dart';
import 'presentation/screens/add_item_screen.dart';
import 'presentation/screens/reports_screen.dart';
import 'presentation/screens/introduction_screen.dart';
import 'providers/app_providers.dart';
import 'providers/guest_mode_banner.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart'; // Add ConnectivityService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  // Register adapters for your models (e.g., Warehouse, UserReport)
  // Hive.registerAdapter(WarehouseAdapter());
  // Hive.registerAdapter(UserReportAdapter());

  final apiService = ApiService();
  final isLoggedIn = await apiService.isLoggedIn();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(MyApp(initialLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool initialLoggedIn;

  const MyApp({super.key, required this.initialLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) {
          final guestModeProvider = GuestModeProvider();
          guestModeProvider.setGuestMode(!initialLoggedIn);
          return guestModeProvider;
        }),
        ChangeNotifierProvider(create: (_) => ConnectivityService()), // Add ConnectivityService
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          final routes = {
            '/': (context) => const IntroductionScreen(),
            '/account': (context) => const AccountScreen(),
            '/explore': (context) => const ExploreScreen(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/manage-roles': (context) => const ManageRolesScreen(),
            '/warehouse-details': (context) {
              final Warehouse warehouse =
              ModalRoute.of(context)!.settings.arguments as Warehouse;
              return WarehouseDetailsScreen(warehouse: warehouse);
            },
            '/reports': (context) => const ReportsScreen(),
            '/logs': (context) => const LogsScreen(),
            '/qr-code': (context) => const ProductScanScreen(),
            '/profile': (context) => const ProfilePage(),
            '/add-item': (context) => const AddItemPage(),
          };

          return MaterialApp(
            title: 'Sales Tracking App',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark().copyWith(
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white70),
                bodyMedium: TextStyle(color: Colors.white70),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ru', 'RU'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            onGenerateRoute: (routeSettings) {
              final guestModeProvider =
              Provider.of<GuestModeProvider>(context, listen: false);
              final connectivityService =
              Provider.of<ConnectivityService>(context, listen: false);

              if (guestModeProvider.isGuestMode &&
                  (routeSettings.name == '/profile' ||
                      routeSettings.name == '/account')) {
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Access denied. Please log in.'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignInScreen()),
                              );
                            },
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Wrap all routes with a Connectivity-aware widget if needed
              return MaterialPageRoute(
                builder: (context) => Builder(
                  builder: (context) {
                    if (!connectivityService.isOnline) {
                      return Scaffold(
                        body: Stack(
                          children: [
                            routes[routeSettings.name]!(context),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.red,
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No Internet Connection',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return routes[routeSettings.name]!(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}