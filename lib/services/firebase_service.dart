import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Saves a job to Firebase under the user's "saved_jobs" collection.
  /// Prevents duplicate saves by checking if the job ID already exists.
  Future<void> saveJobToFirebase(Map<String, dynamic> job) async {
    try {
      // Ensure the user is logged in
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      // Reference to the user's saved jobs collection
      final userJobsRef = _firestore.collection('users').doc(userId).collection('saved_jobs');

      // Extract the unique job ID (assuming 'id' is a required field in the job data)
      final String jobId = job['id'];
      if (jobId.isEmpty) {
        throw Exception('Job data does not contain a valid ID');
      }

      // Check if the job already exists to avoid duplicates
      final querySnapshot = await userJobsRef.where('id', isEqualTo: jobId).get();
      if (querySnapshot.docs.isNotEmpty) {
        print('Job already saved: $jobId');
        return;
      }

      // Add the job to the user's saved jobs
      await userJobsRef.add({
        'id': jobId, // Unique identifier for the job
        'title': job['title'] ?? 'No Title',
        'company_name': job['company_name'] ?? 'No Company',
        'location': job['location'] ?? 'No Location',
        'description': job['description'] ?? 'No Requirements',
        'tags': job['tags'] ?? [],
        'url': job['url'] ?? '',
        'timestamp': FieldValue.serverTimestamp(), // Timestamp for sorting
      });

      print('Job saved successfully: $jobId');
    } catch (e) {
      print('Error saving job to Firebase: $e');
      rethrow; // Rethrow the exception to allow handling upstream
    }
  }

  /// Fetches the user's saved jobs from Firebase, sorted by timestamp (most recent first).
  Future<List<Map<String, dynamic>>> fetchSavedJobs() async {
    try {
      // Ensure the user is logged in
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      // Reference to the user's saved jobs collection
      final userJobsRef = _firestore.collection('users').doc(userId).collection('saved_jobs');

      // Fetch jobs sorted by timestamp (most recent first)
      final querySnapshot = await userJobsRef.orderBy('timestamp', descending: true).get();

      // Convert the documents into a list of maps
      final List<Map<String, dynamic>> jobs =
      querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      return jobs;
    } catch (e) {
      print('Error fetching saved jobs: $e');
      rethrow; // Rethrow the exception to allow handling upstream
    }
  }

  /// Deletes a saved job from Firebase using its unique job ID.
  Future<void> deleteJobFromFirebase(String jobId) async {
    try {
      // Ensure the user is logged in
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      // Reference to the user's saved jobs collection
      final userJobsRef = _firestore.collection('users').doc(userId).collection('saved_jobs');

      // Find the job document with the matching job ID
      final querySnapshot = await userJobsRef.where('id', isEqualTo: jobId).get();
      if (querySnapshot.docs.isEmpty) {
        throw Exception('Job not found in saved jobs');
      }

      // Delete the job document
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('Job deleted successfully: $jobId');
    } catch (e) {
      print('Error deleting job from Firebase: $e');
      rethrow; // Rethrow the exception to allow handling upstream
    }
  }
}