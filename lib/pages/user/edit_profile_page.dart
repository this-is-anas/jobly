import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _jobPreferencesController;
  late TextEditingController _nameController;
  String? _resumePath;
  bool _isLoading = false;
  String? _resumeFileName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _resumeUrl;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _jobPreferencesController = TextEditingController();
    _nameController = TextEditingController();
    _loadUserData();
    _loadLocalImage();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _jobPreferencesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return;
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _emailController.text = data['email'] ?? '';
          _jobPreferencesController.text = data['jobPreferences'] ?? '';
          _nameController.text = data['name'] ?? '';
          _resumeFileName = data['resumeFileName'];
          _resumeUrl = data['resumeUrl'];
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
          _selectedImage = file;
          _localImagePath = path;
        });
      }
    } catch (e) {
      print('Error loading local image: $e');
    }
  }

  Future<void> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userId = _auth.currentUser?.uid ?? '';
      final path = '${directory.path}/profile_$userId.jpg';
      await image.copy(path);
      setState(() {
        _selectedImage = File(path);
        _localImagePath = path;
      });
    } catch (e) {
      print('Error saving image locally: $e');
      rethrow;
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        await _saveImageLocally(File(image.path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createOrUpdateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        final String userId = _auth.currentUser?.uid ?? '';
        if (userId.isEmpty) {
          throw 'User not logged in';
        }
        final userRef = _firestore.collection('users').doc(userId);
        final docSnapshot = await userRef.get();
        if (!docSnapshot.exists) {
          await userRef.set({
            'email': _emailController.text,
            'name': _nameController.text,
            'jobPreferences': _jobPreferencesController.text,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await userRef.update({
            'email': _emailController.text,
            'name': _nameController.text,
            'jobPreferences': _jobPreferencesController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, {
            'email': _emailController.text,
            'name': _nameController.text,
            'jobPreferences': _jobPreferencesController.text,
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
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
        // backgroundColor: Colors.transparent, // Transparent AppBar
        // systemOverlayStyle: SystemUiOverlayStyle(
        //   statusBarColor: Colors.transparent, // Transparent status bar
        //   statusBarIconBrightness: Brightness.light, // Light icons for dark backgrounds
        // ),
      ),
      extendBodyBehindAppBar: true, // Extend body behind AppBar
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFEFBA), // Warm Peach
              const Color(0xFFFFFFFF), // Pure White
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SizedBox.expand(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Picture Section
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : null,
                                child: _selectedImage == null
                                    ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  radius: 18,
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                    onPressed: _showImageSourceDialog,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            icon: const Icon(Icons.person, color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFFE2725B), width: 2.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            icon: const Icon(Icons.email, color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFFE2725B), width: 2.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                        // Job Preferences Field
                        TextFormField(
                          controller: _jobPreferencesController,
                          decoration: InputDecoration(
                            labelText: 'Job Preferences',
                            icon: const Icon(Icons.work, color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFFE2725B), width: 2.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your job preferences';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Save Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createOrUpdateUserProfile,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Save Changes'),
                        ),
                        const SizedBox(height: 200), // Add extra space to test scrolling
                      ],
                    ),
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
        ),
      ),
    );
  }
}