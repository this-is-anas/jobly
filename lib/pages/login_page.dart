import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_fonts/google_fonts.dart'; // Use Google Fonts for custom fonts
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  // Firebase Authentication methods
  Future<String?> _authUser(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null; // Login successful
    } catch (e) {
      return 'Invalid email or password';
    }
  }

  Future<String?> _registerUser(SignupData data) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      return null; // Signup successful
    } catch (e) {
      return 'Email already in use or invalid';
    }
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      return null; // Recovery email sent
    } catch (e) {
      return 'Email not found';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Jobly',
      onLogin: _authUser,
      onSignup: _registerUser,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomePage(),
        ));
      },
      theme: LoginTheme(
        primaryColor: const Color(0xFF0F4C81), // Classic Blue
        accentColor: Colors.grey[300], // Light Gray
        titleStyle: GoogleFonts.montserrat(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyStyle: GoogleFonts.merriweather(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.grey[800],
        ),
        textFieldStyle: GoogleFonts.merriweather(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        buttonStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}


