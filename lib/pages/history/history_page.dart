import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await _firestore
          .collection('user_swipes')
          .where('userId', isEqualTo: userId)
          .where('action', isEqualTo: 'interested') // Only fetch "interested" actions
          .orderBy('timestamp', descending: true) // Show recent swipes first
          .get();

      setState(() {
        _applications = querySnapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching applications: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
          ? const Center(child: Text('No applications found'))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          final application = _applications[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              title: Text(
                application['title'], // Job title
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application['company']), // Company name
                  Text('Applied on: ${DateTime.now().toString().split(' ')[0]}'), // Use timestamp from Firestore
                ],
              ),
              trailing: Chip(
                label: const Text(
                  'Pending', // Default status
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: _getStatusColor('pending'), // Default status color
              ),
              onTap: () {
                // Add navigation to detailed view if needed
              },
            ),
          );
        },
      ),
    );
  }
}