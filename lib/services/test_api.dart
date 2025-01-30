import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = ''; // Replace if regenerated
  const appId = ''; // Replace with your Adzuna App ID

  try {
    final url =
        'https://api.adzuna.com/v1/api/jobs/gb/search/1?app_id=$appId&app_key=$apiKey&results_per_page=10';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Jobs fetched successfully:');
      print(data); // Print the entire API response

      // Extract and display job titles
      final jobs = data['results'];
      for (var job in jobs) {
        print('Title: ${job['title']}');
        print('Company: ${job['company']['display_name']}');
        print('Location: ${job['location']['display_name']}');
        print('---');
      }
    } else {
      print('Failed to fetch jobs. Status code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error fetching jobs: $e');
  }
}