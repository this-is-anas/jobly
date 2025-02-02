import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../assets/components/job_card.dart';
import '../../services/firebase_service.dart';
import '../../services/job_service.dart';
import '../login/login_page.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
  final JobService _jobService = JobService(); // Initialize the JobService
  final FirebaseService _firebaseService = FirebaseService(); // Initialize FirebaseService

  List _jobs = [];
  int _currentIndex = 0; // Tracks the current job being displayed
  bool _isLoading = true; // Loading state

  late AnimationController _animationController; // Animation controller
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  Future _fetchJobs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch jobs from the API
      final jobs = await _jobService.fetchArbeitNowJobs(
        location: 'Berlin',
        remote: true,
        page: 1,
        limit: 10,
      );

      // Preprocess jobs to ensure required fields are present
      final processedJobs = jobs.map((job) {
        return {
          'id': job['url'] ?? UniqueKey().toString(), // Use URL as ID or generate a unique key
          'title': job['title'] ?? 'No Title',
          'company_name': job['company_name'] ?? 'No Company',
          'location': job['location'] ?? 'No Location',
          'description': job['description'] ?? 'No Requirements',
          'tags': job['tags'] ?? [],
          'salaryRange': job['salaryRange'] ?? 'Salary not specified',
          'url': job['url'] ?? '',
        };
      }).toList();

      setState(() {
        _jobs = processedJobs;
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
      _slideAnimation = Tween(
        begin: Offset.zero,
        end: const Offset(-1.0, 0), // Slide left
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

      _animationController.forward().then((_) {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _animationController.reset(); // Reset animation for next card
          });
        }
      });

      // Haptic feedback
      HapticFeedback.lightImpact();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No more jobs available')),
        );
      }
    }
  }

  void _handleSwipeLeft() {
    if (_currentIndex > 0) {
      // Animate slide-out to the right
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(1.0, 0), // Slide right
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

      _animationController.forward().then((_) {
        setState(() {
          _currentIndex--;
          _animationController.reset(); // Reset animation for the next card
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.primary, // Match app bar color
          statusBarIconBrightness: Brightness.light, // Light icons for dark backgrounds
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
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
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation.value,
                child: Opacity(
                  opacity: 1 - _animationController.value,
                  child: JobCard(
                    key: ValueKey(_currentIndex),
                    jobTitle: currentJob['title'] ?? 'No Title',
                    companyName: currentJob['company_name'] ?? 'No Company',
                    location: currentJob['location'] ?? 'No Location',
                    requirements: currentJob['description'] ?? 'No Requirements',
                    jobType: currentJob['tags']?.join(', ') ?? 'Not specified',
                    salaryRange: currentJob['salaryRange'] ?? 'Salary not specified',
                    applyLink: currentJob['url'] ?? '',
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