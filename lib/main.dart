import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

import 'theme/app_theme.dart';

import 'screens/user_account_store.dart';
import 'screens/wardrobe_store.dart';
import 'screens/outfits_store.dart';
import 'screens/style_preferences_store.dart';
import 'screens/my_aesthetic_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load all saved Vestra data before the app starts.
  await UserAccountStore.loadAccount();
  await WardrobeStore.loadItems();
  await OutfitStore.loadOutfits();
  await StylePreferencesStore.loadPreferences();
  await MyAestheticStore.loadAesthetics();

  runApp(const VestraApp());
}

class VestraApp extends StatelessWidget {
  const VestraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vestra',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
