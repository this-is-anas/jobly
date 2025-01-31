import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        // Color Scheme
        primaryColor: const Color(0xFF6A1B9A), // Deep Purple
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6A1B9A), // Deep Purple
          secondary: const Color(0xFF03DAC5), // Cyan Accent
          background: const Color(0xFFF5F5F5), // Light Gray Background
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Gray

        // Text Theme with Nunito Font
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF03DAC5)),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[600]),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A1B9A), // Deep Purple
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
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
          backgroundColor: const Color(0xFF6A1B9A), // Deep Purple
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