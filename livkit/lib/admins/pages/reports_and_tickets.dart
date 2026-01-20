import '../widgets/menu_app_controller.dart';
import '../widgets/responsive.dart';
import 'admins_dashboard.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../widgets/components/header.dart';
import '../widgets/components/system_insights.dart';

import '../widgets/side_menu.dart';
import '../widgets/constants.dart';
import '../widgets/components/tables.dart';
import '../widgets/components/charts.dart';



class AdminsReportsMainScreen extends StatelessWidget {
 const AdminsReportsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuAppController = Provider.of<MenuAppController>(context);

    return Scaffold(
      key: menuAppController.scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
             Expanded(child: SideMenu()),

            const Expanded(
              flex: 5,
              child: AdminsReportPage(),
            ),
          ],
        ),
      ),
    );
  }
}


class AdminsReportPage extends StatelessWidget {
  const AdminsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MAIN CONTENT
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔄 Refresh / Analytics
                      Refresh(),
                      ReportsAndTicketsAnalysis(),
                      SizedBox(height: defaultPadding),

                      // 🔴 REPORTED ABUSE SECTION
                      _sectionTitle('Reported Abuse Management'),
                      SizedBox(height: 10),
                      const AbuseOptionsList(),

                      SizedBox(height: defaultPadding * 1.5),

                      // 🎫 SUPPORT TICKETS SECTION
                      _sectionTitle('Support Tickets Management'),
                      SizedBox(height: 10),
                      const TicketOptionsList(),

                      SizedBox(height: defaultPadding),

                      // MOBILE POLICY DETAILS
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        ReportsPolicyDetails(),
                    ],
                  ),
                ),

                // DESKTOP SIDE PANEL
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),

                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: ReportsPolicyDetails(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SECTION HEADER
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}



class Refresh extends StatelessWidget {
  const Refresh({
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
              "Reports and Ticket Overview",
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
                Navigator.pushNamed(context, '/admins_reports');
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}























class TicketOptionsList extends StatelessWidget {
  const TicketOptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: options.map((item) => _OptionTile(item: item)).toList(),
      ),
    );
  }

  List<AdminOptionItem> _buildOptions(BuildContext context) {
    return [
      AdminOptionItem(
        icon: Icons.support_agent,
        title: 'All Tickets',
        subtitle: 'View all submitted tickets',
        onTap: () => _openDialog(context, 'All Tickets'),
      ),
      AdminOptionItem(
        icon: Icons.priority_high,
        title: 'Priority Tickets',
        subtitle: 'Urgent & escalated issues',
        onTap: () => _openDialog(context, 'Priority Tickets'),
      ),
      AdminOptionItem(
        icon: Icons.subscriptions,
        title: 'Subscription Issues',
        subtitle: 'Billing & premium complaints',
        onTap: () => _openDialog(context, 'Subscription Issues'),
      ),
      AdminOptionItem(
        icon: Icons.payment,
        title: 'Payment Problems',
        subtitle: 'Failed or disputed payments',
        onTap: () => _openDialog(context, 'Payment Problems'),
      ),
      AdminOptionItem(
        icon: Icons.card_giftcard,
        title: 'Gift & Coin Issues',
        subtitle: 'Missing gifts or coin errors',
        onTap: () => _openDialog(context, 'Gift Issues'),
      ),
      AdminOptionItem(
        icon: Icons.person,
        title: 'User Account Issues',
        subtitle: 'Login, bans & profile issues',
        onTap: () => _openDialog(context, 'Account Issues'),
      ),
      AdminOptionItem(
        icon: Icons.schedule,
        title: 'SLA & Response Time',
        subtitle: 'Manage response deadlines',
        onTap: () => _openDialog(context, 'SLA Settings'),
      ),
      AdminOptionItem(
        icon: Icons.assignment_turned_in,
        title: 'Resolved Tickets',
        subtitle: 'Closed & completed tickets',
        onTap: () => _openDialog(context, 'Resolved Tickets'),
      ),
      AdminOptionItem(
        icon: Icons.bar_chart,
        title: 'Support Analytics',
        subtitle: 'Performance & workload stats',
        onTap: () => _openDialog(context, 'Support Analytics'),
      ),
    ];
  }

  void _openDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2D),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Support ticket management goes here.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}






class AbuseOptionsList extends StatelessWidget {
  const AbuseOptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: options.map((item) => _OptionTile(item: item)).toList(),
      ),
    );
  }

  List<AdminOptionItem> _buildOptions(BuildContext context) {
    return [
      AdminOptionItem(
        icon: Icons.report,
        title: 'User Reports',
        subtitle: 'View reported users & accounts',
        onTap: () => _openDialog(context, 'User Reports'),
      ),
      AdminOptionItem(
        icon: Icons.videocam_off,
        title: 'Stream Violations',
        subtitle: 'Live stream abuse & violations',
        onTap: () => _openDialog(context, 'Stream Violations'),
      ),
      AdminOptionItem(
        icon: Icons.chat_bubble_outline,
        title: 'Chat Abuse',
        subtitle: 'Harassment, spam & hate speech',
        onTap: () => _openDialog(context, 'Chat Abuse'),
      ),
      AdminOptionItem(
        icon: Icons.card_giftcard,
        title: 'Gift Fraud & Abuse',
        subtitle: 'Fake gifts & coin manipulation',
        onTap: () => _openDialog(context, 'Gift Abuse'),
      ),
      AdminOptionItem(
        icon: Icons.warning_amber,
        title: 'Warnings & Strikes',
        subtitle: 'Issue warnings or strikes',
        onTap: () => _openDialog(context, 'Warnings & Strikes'),
      ),
      AdminOptionItem(
        icon: Icons.block,
        title: 'Bans & Suspensions',
        subtitle: 'Temporary or permanent bans',
        onTap: () => _openDialog(context, 'Bans & Suspensions'),
      ),
      AdminOptionItem(
        icon: Icons.photo_library,
        title: 'Evidence & Attachments',
        subtitle: 'Images, clips & screenshots',
        onTap: () => _openDialog(context, 'Evidence'),
      ),
      AdminOptionItem(
        icon: Icons.policy,
        title: 'Community Guidelines',
        subtitle: 'Rules & enforcement policies',
        onTap: () => _openDialog(context, 'Community Guidelines'),
      ),
      AdminOptionItem(
        icon: Icons.history,
        title: 'Moderation Logs',
        subtitle: 'Admin actions & history',
        onTap: () => _openDialog(context, 'Moderation Logs'),
      ),
    ];
  }

  void _openDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2D),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Moderation controls will be managed here.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final AdminOptionItem item;

  const _OptionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.deepPurpleAccent),
      title: Text(
        item.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white38,
      ),
      onTap: item.onTap,
    );
  }
}


class AdminOptionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AdminOptionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}