import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
// Separate widget for Home Content



class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
  final JobService _jobService = JobService(); // Initialize the JobService
  final FirebaseService _firebaseService = FirebaseService(); // Initialize FirebaseService
  List<dynamic> _jobs = [];
  int _currentIndex = 0; // Tracks the current job being displayed
  bool _isLoading = true; // Loading state
  AnimationController? _animationController; // Nullable animation controller
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState(); // Ensure this is called first
    _fetchJobs(); // Fetch jobs when the widget initializes

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this, // Use `this` because of TickerProviderStateMixin
      duration: const Duration(milliseconds: 500),
    );

    // Default slide animation (no movement)
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController?.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final jobs = await _jobService.fetchUsaJobs(
        keyword: 'Software Engineer', // Optional: Filter by keyword
        location: 'Washington, DC', // Optional: Filter by location
        jobCategoryCode: '2210', // IT jobs
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

      // Animate slide-out to the left
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1.0, 0), // Slide left
      ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut));

      _animationController!.forward().then((_) {
        setState(() {
          _currentIndex++;
          _animationController!.reset(); // Reset animation for next card
        });
      });

      // Haptic feedback
      HapticFeedback.lightImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more jobs available')),
      );
    }
  }

  void _handleSwipeLeft() {
    if (_currentIndex > 0) {
      // Animate slide-out to the right
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(1.0, 0), // Slide right
      ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut));

      _animationController!.forward().then((_) {
        setState(() {
          _currentIndex--;
          _animationController!.reset(); // Reset animation for next card
        });
      });

      // Haptic feedback
      HapticFeedback.lightImpact();
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
      body: Center(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            // Detect swipe direction based on velocity
            if (details.primaryVelocity! > 0) {
              // Swiped left
              _handleSwipeLeft();
            } else if (details.primaryVelocity! < 0) {
              // Swiped right
              _handleSwipeRight();
            }
          },
          child: AnimatedBuilder(
            animation: _animationController ?? AlwaysStoppedAnimation(0), // Handle null case
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation?.value ?? Offset.zero, // Handle null case
                child: Opacity(
                  opacity: 1 - (_animationController?.value ?? 0), // Handle null case
                  child: JobCard(
                    key: ValueKey(_currentIndex), // Unique key for each job
                    jobTitle: currentJob['PositionTitle'] ?? 'No Title',
                    companyName: currentJob['OrganizationName'] ?? 'No Company',
                    location: currentJob['LocationName'] ?? 'No Location',
                    requirements: currentJob['QualificationSummary'] ?? 'No Requirements',
                    experience: currentJob['experience'] ?? 'Experience not specified',
                    roleAndResponsibility:
                    currentJob['role_and_responsibility'] ?? 'Role & Responsibility not specified',
                    applyLink: currentJob['PositionURI'] ?? '', // Use the PositionURI from the API
                    onSwipeRight: _handleSwipeRight,
                    onSwipeLeft: _handleSwipeLeft,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}