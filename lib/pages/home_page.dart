import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobly/pages/user/profile_page.dart';

import '../assets/components/job_card.dart';
import '../services/firebase_service.dart';
import '../services/job_service.dart';
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
      body: SafeArea(child: _pages[_pageIndex]), // Display the selected page
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
  final JobService _jobService = JobService(); // Initialize the JobService
  final FirebaseService _firebaseService = FirebaseService(); // Initialize FirebaseService
  List<dynamic> _jobs = [];
  int _currentIndex = 0; // Tracks the current job being displayed
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchJobs(); // Fetch jobs when the widget initializes
  }

  Future<void> _fetchJobs() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final jobs = await _jobService.fetchJobs(
        location: 'India', // Optional: Filter by location
        title: 'Software Engineer', // Optional: Filter by job title
        limit: 20, // Fetch up to 20 jobs
      );
      setState(() {
        _jobs = jobs;
        _currentIndex = 0; // Reset to the first job
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching jobs: $e');
    }
  }

  void _handleSwipeRight() {
    if (_currentIndex < _jobs.length - 1) {
      final currentJob = _jobs[_currentIndex];
      _firebaseService.saveJobToFirebase(currentJob); // Save the job to Firebase
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tech Jobs')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_jobs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tech Jobs')),
        body: const Center(child: Text('No tech jobs available')),
      );
    }

    final currentJob = _jobs[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Jobs'),
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
      body: SingleChildScrollView( // Make the content scrollable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: JobCard(
                jobTitle: currentJob['title'] ?? 'No Title',
                companyName: currentJob['company'] ?? 'No Company',
                location: currentJob['location'] ?? 'No Location',
                requirements: currentJob['job_description'] ?? 'No Requirements',
                experience: currentJob['experience'] ?? 'Experience not specified',
                roleAndResponsibility:
                currentJob['role_and_responsibility'] ?? 'Role & Responsibility not specified',
                onSwipeRight: _handleSwipeRight,
                onSwipeLeft: _handleSwipeLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}