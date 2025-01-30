import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveJobToFirebase(Map<String, dynamic> jobData) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Save the job data to Firestore under the user's "saved_jobs" collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_jobs')
          .add(jobData);

      print('Job saved successfully');
    } catch (e) {
      print('Error saving job to Firebase: $e');
      throw Exception('Failed to save job');
    }
  }
}