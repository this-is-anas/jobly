import 'package:cloud_firestore/cloud_firestore.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch jobs from Firestore
  Future<List<dynamic>> fetchJobs() async {
    try {
      final querySnapshot = await _firestore.collection('jobs').get();
      final List<dynamic> jobs = querySnapshot.docs.map((doc) => doc.data()).toList();
      print('Fetched ${jobs.length} jobs: $jobs'); // Log the fetched jobs
      return jobs;
    } catch (e) {
      print('Error fetching jobs: $e');
      throw Exception('Failed to load jobs');
    }
  }
}