import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _jobs = []; // List of jobs fetched from Firestore
  int _currentIndex = 0; // Tracks the current job being displayed

  @override
  void initState() {
    super.initState();
    _fetchJobs(); // Fetch jobs when the widget initializes
  }

  Future<void> _fetchJobs() async {
    try {
      final querySnapshot = await _firestore.collection('jobs').get();
      setState(() {
        _jobs = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  void _handleSwipeRight() {
    if (_currentIndex < _jobs.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more jobs available')),
      );
    }
  }

  void _handleSwipeLeft() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are at the first job')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_jobs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Listings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentJob = _jobs[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Listings'),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: JobCard(
              jobTitle: currentJob['title'],
              companyName: currentJob['company'],
              location: currentJob['location'],
              requirements: currentJob['requirements'],
              onSwipeRight: _handleSwipeRight,
              onSwipeLeft: _handleSwipeLeft,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSwipeLeft,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Not Interested'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _handleSwipeRight,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Interested'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}