import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the status bar color and brightness globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // Light icons for dark backgrounds
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jobly',
      theme: ThemeData(
        // Primary and Secondary Colors
        primaryColor: const Color(0xFFAD8B73), // Terracotta Brown
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFAD8B73), // Terracotta Brown
          secondary: const Color(0xFFCEAB93), // Beige-Brown
          // surface: const Color(0x00fffbe9), // Off-White Background
        ),
        scaffoldBackgroundColor: const Color(0x00fffbe9), // Off-White for Scaffold

        // Text Theme with Nunito Font
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFFAD8B73)),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFAD8B73), // Terracotta Brown
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x00fffbe9), // Off-White
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),

        // App Bar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFAD8B73), // Terracotta Brown
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const AuthPage(),
    );
  }
}