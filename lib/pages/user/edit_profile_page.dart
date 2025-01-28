import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _jobPreferencesController;
  String? _resumePath;
  bool _isLoading = false;
  String? _resumeFileName;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'john.doe@example.com');
    _jobPreferencesController =
        TextEditingController(text: 'Software Developer');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _jobPreferencesController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _resumePath = result.files.single.path;
          _resumeFileName = result.files.single.name;
        });

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resume uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading resume: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 1));

        // Here you would typically send data to your backend
        final userData = {
          'email': _emailController.text,
          'jobPreferences': _jobPreferencesController.text,
          'resumePath': _resumePath,
          'resumeFileName': _resumeFileName,
        };

        // Print the data for now (replace with actual API call)
        print('Saving user data: $userData');

        if (context.mounted) {
          // Show success message and pop back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, userData); // Return the updated data
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      icon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Resume'),
                    subtitle: Text(_resumeFileName ?? 'No file selected'),
                    trailing: ElevatedButton(
                      onPressed: _isLoading ? null : _pickResume,
                      child: const Text('Upload'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jobPreferencesController,
                    decoration: const InputDecoration(
                      labelText: 'Job Preferences',
                      icon: Icon(Icons.work),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your job preferences';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
