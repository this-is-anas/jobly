import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State createState() => _HistoryPageState();
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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      final querySnapshot =
      await _firestore.collection('users').doc(userId).collection('saved_jobs').get();
      final jobs = querySnapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _savedJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching saved jobs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
      ),
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
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _savedJobs.isEmpty
              ? const Center(child: Text('No saved jobs'))
              : ListView.builder(
            itemCount: _savedJobs.length,
            itemBuilder: (context, index) {
              final job = _savedJobs[index];
              return ListTile(
                title: Text(job['title'] ?? 'No Title'),
                subtitle: Text(job['company'] ?? 'No Company'),
                trailing: Text(job['location'] ?? 'No Location'),
              );
            },
          ),
        ),
      ),
    );
  }
}