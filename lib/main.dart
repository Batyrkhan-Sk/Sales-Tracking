import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'presentation/models/auth_data.dart';
import 'presentation/models/warehouse.dart';

import 'presentation/screens/explore_screen.dart';
import 'presentation/screens/sign_in_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/account_screen.dart';
import 'presentation/screens/manage_roles_screen.dart';
import 'presentation/screens/warehouse_details_screen.dart';
import 'presentation/screens/qr_code_screen.dart';
import 'presentation/screens/logs_screen.dart';
import 'presentation/screens/profile_page.dart';
import 'presentation/screens/add_item_screen.dart';
import 'presentation/screens/reports_screen.dart';
import 'presentation/screens/introduction_screen.dart';
import 'presentation/screens/set_pin_screen.dart';

import 'presentation/widgets/offline_banner_wrapper.dart';

import 'providers/app_providers.dart';
import 'providers/guest_mode_banner.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(AuthDataAdapter());
  await Hive.openBox<AuthData>('auth');

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
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
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
            '/qr-code': (context) => const QRCodeScreen(),
            '/profile': (context) => const ProfilePage(),
            '/add-item': (context) => const AddItemPage(),
            '/set-pin': (context) => const SetPinScreen(),
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
            initialRoute: '/', // или '/explore' если хочешь вход сразу после isLoggedIn
            onGenerateRoute: (settings) {
              final guestModeProvider =
              Provider.of<GuestModeProvider>(context, listen: false);

              // Защита от неавторизованного входа
              if (guestModeProvider.isGuestMode &&
                  (settings.name == '/profile' || settings.name == '/account')) {
                return MaterialPageRoute(
                  builder: (context) => OfflineBannerWrapper(
                    child: Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Access denied. Please log in.'),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/signin');
                              },
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              final builder = routes[settings.name];
              if (builder != null) {
                return MaterialPageRoute(
                  builder: (context) => OfflineBannerWrapper(
                    child: builder(context),
                  ),
                );
              } else {
                return MaterialPageRoute(
                  builder: (context) => OfflineBannerWrapper(
                    child: const Scaffold(
                      body: Center(child: Text('404 — Page not found')),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
