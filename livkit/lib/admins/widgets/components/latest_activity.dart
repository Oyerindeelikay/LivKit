import 'my_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class FileInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ActivityCard(
          icon: Icons.description,
          title: 'Doctors',
          fileCount: '1328 Files',
          storageUsed: '1.9GB',
          progressValue: 0.5,
          color: Colors.blue,
        ),
        ActivityCard(
          icon: Icons.cloud,
          title: 'Patients',
          fileCount: '1328 Files',
          storageUsed: '2.9GB',
          progressValue: 0.7,
          color: Colors.orange,
        ),
        ActivityCard(
          icon: Icons.cloud_circle,
          title: 'Total Appointment',
          fileCount: '1328 Files',
          storageUsed: '1GB',
          progressValue: 0.3,
          color: Colors.lightBlue,
        ),
        ActivityCard(
          icon: Icons.storage,
          title: 'Total Schedule',
          fileCount: '5328 Files',
          storageUsed: '7.3GB',
          progressValue: 0.9,
          color: Colors.blueGrey,
        ),
      ],
    );
  }
}

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String fileCount;
  final String storageUsed;
  final double progressValue;
  final Color color;

  ActivityCard({
    required this.icon,
    required this.title,
    required this.fileCount,
    required this.storageUsed,
    required this.progressValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2D3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[800],
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              fileCount,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              storageUsed,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

