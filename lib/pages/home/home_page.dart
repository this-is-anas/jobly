import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../assets/components/job_card.dart';
import '../../services/firebase_service.dart';
import '../../services/job_service.dart';
import '../history/history_page.dart';
import '../login/login_page.dart';
import '../user/profile_page.dart';
import 'home_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0; // Tracks the current page index

  final List _pages = [
    const HomeContent(), // Home Content (not HomePage itself)
    const ProfilePage(), // Profile Page
    const HistoryPage(), // History Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Ensure bottom bar is above content
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFEFBA), // Warm Peach
              const Color(0xFFFFFFFF), // Pure White
            ],
          ),
        ),
        child: _pages[_pageIndex], // Display the selected page
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Theme.of(context).colorScheme.primary, // Use primary color
        buttonBackgroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _pageIndex,
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.history, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}


