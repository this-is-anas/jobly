import 'dart:convert';
import 'package:http/http.dart' as http;

class JobService {
  final String _email = ''; // Replace with your email
  final String _authKey = ''; // Replace with your USAJobs API key

  Future<List<dynamic>> fetchUsaJobs({
    String? keyword,
    String? location,
    String? jobCategoryCode,
  }) async {
    const String baseUrl = 'https://data.usajobs.gov/api/search';

    // Build query parameters
    final Map<String, dynamic> queryParams = {
      if (keyword != null && keyword.isNotEmpty) 'Keyword': keyword,
      if (location != null && location.isNotEmpty) 'LocationName': location,
      if (jobCategoryCode != null && jobCategoryCode.isNotEmpty)
        'JobCategoryCode': jobCategoryCode,
    };

    try {
      final response = await http.get(
        Uri.parse(baseUrl).replace(queryParameters: queryParams),
        headers: {
          'Host': 'data.usajobs.gov',
          'User-Agent': _email,
          'Authorization-Key': _authKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> jobs =
            data['SearchResult']['SearchResultItems'] ?? [];
        return jobs.map((item) => item['MatchedObjectDescriptor']).toList();
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