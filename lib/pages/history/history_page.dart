import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _savedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedJobs();
  }

  Future<void> _fetchSavedJobs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch saved jobs from Firestore
      final QuerySnapshot querySnapshot =
      await _firestore.collection('users').doc(userId).collection('saved_jobs').get();

      // Safely map the documents to a list of maps
      final List<Map<String, dynamic>> jobs = querySnapshot.docs
          .map((doc) => Map<String, dynamic>.from(doc.data() as Map))
          .toList();

      setState(() {
        _savedJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load saved jobs: $e')),
      );
    }
  }

  Future<void> _deleteJob(String jobId) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Delete the job from Firestore
      final userJobsRef = _firestore.collection('users').doc(userId).collection('saved_jobs');
      final querySnapshot = await userJobsRef.where('id', isEqualTo: jobId).get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Remove the job from the local list
      setState(() {
        _savedJobs.removeWhere((job) => job['id'] == jobId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job removed from history')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting job: $e')),
      );
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No application link available')),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open application link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Jobs"),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFEFBA), // Warm Peach
              Colors.white, // Pure White
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedJobs.isEmpty
            ? const Center(child: Text('No saved jobs available'))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _savedJobs.length,
          itemBuilder: (context, index) {
            final job = _savedJobs[index];
            // Safely handle null values
            final String jobId = job['id'] ?? job['url'] ?? UniqueKey().toString();
            final String jobTitle = job['title'] ?? 'No Title';
            final String companyName = job['company_name'] ?? 'No Company';
            final String location = job['location'] ?? 'No Location';
            final String applyUrl = job['url'] ?? '';

            return Dismissible(
              key: Key(jobId),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                _deleteJob(jobId);
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    jobTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(companyName),
                      const SizedBox(height: 4),
                      Text(location),
                    ],
                  ),
                  onTap: () {
                    // Navigate to job details or open the apply link
                    if (applyUrl.isNotEmpty) {
                      _launchURL(applyUrl);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }}