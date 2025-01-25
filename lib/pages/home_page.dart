import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  //signOut
  // void signUserOut(BuildContext context) async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     Navigator.pushReplacementNamed(MaterialPageRoute(
  //       builder: (context) => const LoginPage(),
  //     )); // Replace with your login route
  //   } catch (e) {
  //     print("Error signing out: $e");
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page'), actions: [IconButton(onPressed: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ));
      }, icon: Icon(Icons.logout, size: 30,))],backgroundColor: Colors.grey,),
      body: const Center(child: Text('Welcome!')),
    );
  }
}