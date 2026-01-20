
import '../responsive.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Platform Overview",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/admins_dashboard');
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        const FileInfoCard(),
      ],
    );
  }
}

class FileInfoCard extends StatelessWidget {
  const FileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPhone = constraints.maxWidth < 600;
        final cardWidth =
            isPhone ? constraints.maxWidth * 0.9 : constraints.maxWidth / 4 - 16;
        final spacing = isPhone ? 10.0 : 16.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: [
              ActivityCard(
                icon: FontAwesomeIcons.userGroup,
                title: 'Total Creators',
                fileCount: '8,421 Accounts',
                storageUsed: 'Verified & Active',
                progressValue: 0.75,
                color: Colors.blueAccent,
                width: cardWidth,
              ),
              ActivityCard(
                icon: FontAwesomeIcons.video,
                title: 'Live Streams',
                fileCount: '312 Live Now',
                storageUsed: 'Peak: 1.2K Today',
                progressValue: 0.55,
                color: Colors.purpleAccent,
                width: cardWidth,
              ),
              ActivityCard(
                icon: FontAwesomeIcons.eye,
                title: 'Total Viewers',
                fileCount: '124K Watching',
                storageUsed: 'Avg Watch Time',
                progressValue: 0.68,
                color: Colors.greenAccent,
                width: cardWidth,
              ),
              ActivityCard(
                icon: FontAwesomeIcons.triangleExclamation,
                title: 'Reports & Flags',
                fileCount: '47 Pending',
                storageUsed: 'Needs Review',
                progressValue: 0.35,
                color: Colors.redAccent,
                width: cardWidth,
              ),
            ],
          ),
        );
      },
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
  final double width;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.fileCount,
    required this.storageUsed,
    required this.progressValue,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: const Color(0xFF2A2D3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.18),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Colors.grey[800],
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              fileCount,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              storageUsed,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
