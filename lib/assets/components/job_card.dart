import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String requirements;
  final String? experience; // Add a new parameter for experience
  final String? roleAndResponsibility; // Add a new parameter for role_and_responsibility
  final VoidCallback onSwipeRight; // Action for "Interested"
  final VoidCallback onSwipeLeft; // Action for "Not Interested"

  const JobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.requirements,
    this.experience, // Optional parameter for experience
    this.roleAndResponsibility, // Optional parameter for role_and_responsibility
    required this.onSwipeRight,
    required this.onSwipeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Detect swipe direction based on velocity
        if (details.primaryVelocity! > 0) {
          // Swiped left
          onSwipeLeft();
        } else if (details.primaryVelocity! < 0) {
          // Swiped right
          onSwipeRight();
        }
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jobTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                companyName,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              if (experience != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Experience: $experience',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
              if (roleAndResponsibility != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.task, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Role & Responsibility: $roleAndResponsibility',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                requirements,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}