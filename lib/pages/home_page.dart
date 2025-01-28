import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:jobly/pages/user/profile_page.dart';
import '../assets/components/job_card.dart';
import 'history/history_page.dart';
import 'login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0; // Tracks the current page index

  // Define pages from the `pages` directory
  final List<Widget> _pages = [
    const HomeContent(), // Home Content (not HomePage itself)
    const ProfilePage(), // Profile Page
    const HistoryPage(), // History Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      extendBody: true, // Ensure bottom bar is above content
      body: _pages[_pageIndex], // Display the selected page
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.blue, // Color of the navigation bar
        buttonBackgroundColor: Colors.blue, // Background color of the selected icon
        backgroundColor: Colors.white, // Background color behind the navigation bar
        height: 60, // Height of the navigation bar
        animationDuration: const Duration(milliseconds: 300), // Animation duration
        index: _pageIndex, // Current selected index
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white), // Home icon
          Icon(Icons.person, size: 30, color: Colors.white), // Profile icon
          Icon(Icons.history, size: 30, color: Colors.white), // History icon
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index; // Update the selected index
          });
        },
      ),
    );
  }
}

// Separate widget for Home Content
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout), // Logout icon
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Add JobCard widgets here
          JobCard(
            jobTitle: 'Flutter Developer',
            companyName: 'Tech Corp',
            location: 'Remote',
            requirements: '2+ years of experience in Flutter, Dart, and REST APIs.',
          ),
          JobCard(
            jobTitle: 'Backend Engineer',
            companyName: 'Data Inc.',
            location: 'New York',
            requirements: 'Experience with Node.js, Express, and MongoDB.',
          ),
          JobCard(
            jobTitle: 'UI/UX Designer',
            companyName: 'Design Hub',
            location: 'San Francisco',
            requirements: 'Proficiency in Figma, Adobe XD, and wireframing tools.',
          ),
        ],
      ),
    );
  }
}