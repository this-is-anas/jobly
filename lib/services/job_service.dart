import 'dart:convert';
import 'package:http/http.dart' as http;

class JobService {
  // Fetch jobs from the ArbeitNow API
  Future<List> fetchArbeitNowJobs({
    String? location,
    bool? remote,
    int page = 1,
    int limit = 10,
  }) async {
    const String baseUrl = 'https://arbeitnow.com/api/job-board-api';

    // Build query parameters
    final Map<String, dynamic> queryParams = {
      if (location != null && location.isNotEmpty) 'location': location,
      if (remote != null) 'remote': remote.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    try {
      final response = await http.get(
        Uri.parse(baseUrl).replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List jobs = data['data'] ?? [];
        return jobs;
      } else {
        print('Failed to fetch jobs. Status code: ${response.statusCode}');
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      throw Exception('Failed to load jobs');
    }
  }
}