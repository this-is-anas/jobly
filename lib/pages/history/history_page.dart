import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace this with your actual job application data
    final List<Map<String, dynamic>> applications = [
      {
        'companyName': 'Tech Corp',
        'position': 'Flutter Developer',
        'appliedDate': '2024-03-20',
        'status': 'Pending'
      },
      {
        'companyName': 'Digital Solutions',
        'position': 'Mobile Developer',
        'appliedDate': '2024-03-19',
        'status': 'Reviewed'
      },
      {
        'companyName': 'Innovation Labs',
        'position': 'Software Engineer',
        'appliedDate': '2024-03-18',
        'status': 'Rejected'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              title: Text(
                application['position'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application['companyName']),
                  Text('Applied on: ${application['appliedDate']}'),
                ],
              ),
              trailing: Chip(
                label: Text(
                  application['status'],
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _getStatusColor(application['status']),
              ),
              onTap: () {
                // Add navigation to detailed view if needed
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
