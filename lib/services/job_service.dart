import 'dart:convert';
import 'package:http/http.dart' as http;

class JobService {
  final String apiKey = 'sk-live-FLN97QTUChuABCuiJvQ3oA6st6bK8a49xGHNc2yk'; // Replace with your actual API key

  Future<List<dynamic>> fetchJobs({
    String? location,
    String? title,
    String? company,
    String? experience,
    String? jobType,
    int limit = 10, // Default limit is 10 jobs
  }) async {
    var url = 'https://jobs.indianapi.in/jobs';

    // Add query parameters
    final Map<String, dynamic> queryParams = {
      if (location != null && location.isNotEmpty) 'location': location,
      if (title != null && title.isNotEmpty) 'title': title,
      if (company != null && company.isNotEmpty) 'company': company,
      if (experience != null && experience.isNotEmpty) 'experience': experience,
      if (jobType != null && jobType.isNotEmpty) 'job_type': jobType,
      'limit': limit.toString(),
    };

    try {
      print('Fetching jobs with URL: $url');
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: {
          'X-Api-Key': apiKey, // Include the API key in the header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Log the full API response
        return data; // Return the list of jobs
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