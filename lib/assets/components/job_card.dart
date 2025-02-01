import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class JobCard extends StatefulWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String? requirements; // Optional
  final String? jobType; // Optional
  final String? salaryRange; // Optional
  final String applyLink; // Required
  final VoidCallback? onSwipeRight; // Optional
  final VoidCallback? onSwipeLeft; // Optional
  final bool remote; // Optional

  const JobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.applyLink,
    this.requirements,
    this.jobType,
    this.salaryRange,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.remote = false, // Default to false if not provided
  });

  @override
  State createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Fade-in animation
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Slide-up animation
    _slideAnimation = Tween(
      begin: const Offset(0, 0.2), // Start slightly below
      end: Offset.zero, // End at the original position
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchApplyLink(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No application link available')),
      );
      return;
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open application link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners for the card
          ),
          child: SizedBox(
            height: 400, // Fixed height for the card
            child: Column(
              children: [
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Title
                        Text(
                          widget.jobTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Company Name
                        Row(
                          children: [
                            const Icon(Icons.business, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.companyName,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Location and Remote Tag
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.location,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            if (widget.remote)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Remote',
                                  style: TextStyle(fontSize: 12, color: Colors.green),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Experience Field
                        if (widget.jobType != null)
                          Row(
                            children: [
                              const Icon(Icons.work, size: 16, color: Colors.blue), // Changed icon to "work"
                              const SizedBox(width: 4),
                              Text(
                                'Job Type: ${widget.jobType}', // Updated label to "Job Type"
                                style: const TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        // Salary Field (New Field Below Experience)
                        if (widget.salaryRange != null)
                          Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Salary: ${widget.salaryRange}',
                                style: const TextStyle(fontSize: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        // Requirements
                        if (widget.requirements != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description:',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              HtmlWidget(
                                widget.requirements!,
                                textStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _launchApplyLink(context, widget.applyLink),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Apply Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
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