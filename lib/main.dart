import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'utils/transition_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress DevTools warnings for web
  if (kIsWeb) {
    // Ignore DevTools extension errors
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeService.instance,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'HabitHero',
            debugShowCheckedModeBanner: false,
            theme: themeService.lightTheme,
            darkTheme: themeService.darkTheme,
            themeMode: themeService.themeMode,
            home: LoginScreen(),
            onGenerateRoute: (settings) {
              // Use fade transition for all routes
              switch (settings.name) {
                case '/':
                  return createFadeRoute(LoginScreen());
                default:
                  return createFadeRoute(LoginScreen());
              }
            },
          );
        },
      ),
    );
  }
}
