import 'dart:convert';
import 'package:http/http.dart' as http;

class JobService {
  final String apiKey = ''; // Replace if regenerated
  final  String appId = ''; // Replace with your Adzuna App ID

  Future<List<dynamic>> fetchJobs() async {
    final url =
        'https://api.adzuna.com/v1/api/jobs/gb/search/1?app_id=$appId&app_key=$apiKey&results_per_page=10';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results']; // Extract the list of jobs from the API response
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