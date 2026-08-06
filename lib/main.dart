import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService.init();

    runZonedGuarded(
      () {
        runApp(const MyApp());
      },
      (error, stack) {
        debugPrint("ERROR: $error");
        debugPrint("$stack");
      },
    );
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: GoogleFonts.cairo().fontFamily,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.textDark,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
