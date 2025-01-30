import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:jobly/pages/login/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name = "John Doe";
  String? _email;
  String? _jobPreferences;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLocalImage();
  }

  Future<void> _loadUserData() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return;

      final docSnapshot =
      await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _name = data['name'] ?? 'John Doe';
          _email = data['email'] ?? '';
          _jobPreferences = data['jobPreferences'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadLocalImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userId = _auth.currentUser?.uid ?? '';
      final path = '${directory.path}/profile_$userId.jpg';
      final file = File(path);

      if (await file.exists()) {
        setState(() {
          _profileImage = file;
        });
      }
    } catch (e) {
      print('Error loading local image: $e');
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );

    if (updatedData != null && updatedData is Map<String, dynamic>) {
      setState(() {
        _name = updatedData['name'];
        _email = updatedData['email'];
        _jobPreferences = updatedData['jobPreferences'];
      });
    }

    _loadLocalImage();
  }

  Future<void> _logout() async {
    await _auth.signOut(); // Logs out from Firebase
    if (context.mounted) {
      // Navigate back to LoginPage after logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false, // Removes all previous routes from stack
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Information Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfoRow(Icons.person, "Name", _name ?? "John Doe"),
                    const Divider(),
                    _buildProfileInfoRow(Icons.email, "Email", _email ?? "Email not available"),
                    const Divider(),
                    _buildProfileInfoRow(Icons.work, "Job Preferences", _jobPreferences ?? "Not set"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Logout Button
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build profile info row
  Widget _buildProfileInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}