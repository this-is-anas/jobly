import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String? jobTitle;
  final String? companyName;
  final String? location;
  final String? requirements;
  final VoidCallback onSwipeRight; // Triggered when swiped right
  final VoidCallback onSwipeLeft; // Triggered when swiped left

  const JobCard({
    super.key,
    this.jobTitle,
    this.companyName,
    this.location,
    this.requirements,
    required this.onSwipeRight,
    required this.onSwipeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swiped left (not interested)
            onSwipeLeft();
          } else if (details.primaryVelocity! < 0) {
            // Swiped right (interested)
            onSwipeRight();
          }
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: double.infinity, // Full width of the parent
            height: 300, // Fixed height for all cards
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobTitle ?? 'No Title', // Default value if jobTitle is null
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  companyName ?? 'No Company', // Default value if companyName is null
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  location ?? 'No Location', // Default value if location is null
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Requirements:",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      requirements ?? 'No Requirements', // Default value if requirements is null
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}