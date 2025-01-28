import 'package:flutter/material.dart';

import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _email = 'john.doe@example.com';
  String _jobPreferences = 'Software Developer';
  String _resumeFileName = 'resume.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture Section
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'lib/assets/google.png'), // Add this image to your assets
            ),
            const SizedBox(height: 16),

            // User Name Section
            const Text(
              'John Doe', // Replace with actual user name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // User Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.email, 'Email', _email),
                    const Divider(),
                    _buildInfoRow(Icons.description, 'Resume', _resumeFileName),
                    const Divider(),
                    _buildInfoRow(
                        Icons.work, 'Job Preferences', _jobPreferences),
                  ],
                ),
              ),
            ),

            // Edit Button
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );

                if (result != null && mounted) {
                  setState(() {
                    _email = result['email'];
                    _jobPreferences = result['jobPreferences'];
                    _resumeFileName =
                        result['resumeFileName'] ?? _resumeFileName;
                  });
                }
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
