import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this package
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  // Firebase Authentication for Email/Password
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

  // Google Sign-In
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to HomePage after successful Google Sign-In
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FlutterLogin UI
          FlutterLogin(
            title: 'Jobly',
            onLogin: _authUser,
            onSignup: _registerUser,
            onRecoverPassword: _recoverPassword,
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
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
          ),

          // Google Sign-In Button (Positioned at the bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => _signInWithGoogle(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                icon: Image.asset(
                  'assets/images/google.png', // Add a Google logo asset
                  height: 24,
                  width: 24,
                ),
                label: Text(
                  'Sign in with Google',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}