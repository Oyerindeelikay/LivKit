import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../constants.dart';

class StorageDetails extends StatefulWidget {
  const StorageDetails({super.key});

  @override
  State<StorageDetails> createState() => _StorageDetailsState();
}

class _StorageDetailsState extends State<StorageDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeSlide =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(String label) {
    debugPrint("Clicked: $label");
  }


  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(_fadeSlide),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "System Insights",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// SYSTEM LOAD / BANDWIDTH
              Center(
                child: CircularPercentIndicator(
                  radius: 85,
                  lineWidth: 10,
                  percent: 0.61,
                  animation: true,
                  animationDuration: 900,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "61%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Server Load",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.grey.shade800,
                  progressColor: Colors.greenAccent,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),

              const SizedBox(height: 24),

              /// CLICKABLE METRICS
              _SidebarItem(
                icon: Icons.cloud_upload,
                color: Colors.blueAccent,
                title: "Stream Upload Traffic",
                subtitle: "High activity",
                onTap: () => _onItemTap("Stream Upload Traffic"),
              ),
              _SidebarItem(
                icon: Icons.shield,
                color: Colors.orangeAccent,
                title: "Moderation Queue",
                subtitle: "Items awaiting review",
                onTap: () => _onItemTap("Moderation Queue"),
              ),
              _SidebarItem(
                icon: Icons.warning_amber_rounded,
                color: Colors.redAccent,
                title: "Policy Alerts",
                subtitle: "Flagged content",
                onTap: () => _onItemTap("Policy Alerts"),
              ),
              _SidebarItem(
                icon: Icons.storage_rounded,
                color: Colors.purpleAccent,
                title: "Media Storage Usage",
                subtitle: "Optimized",
                onTap: () => _onItemTap("Media Storage Usage"),
              ),

              const SizedBox(height: 18),

              /// QUICK ACTIONS
              const Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionChip(
                    label: "Review Flags",
                    icon: Icons.flag,
                    onTap: () => _onItemTap("Review Flags"),
                  ),
                  _ActionChip(
                    label: "System Logs",
                    icon: Icons.receipt_long,
                    onTap: () => _onItemTap("System Logs"),
                  ),
                  _ActionChip(
                    label: "Audit Streams",
                    icon: Icons.video_camera_back,
                    onTap: () => _onItemTap("Audit Streams"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ========================
/// SIDEBAR ITEM
/// ========================
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

/// ========================
/// ACTION CHIP
/// ========================
class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class LivestreamsDetails extends StatefulWidget {
  const LivestreamsDetails({super.key});

  @override
  State<LivestreamsDetails> createState() => _LivestreamsDetailsState();
}

class _LivestreamsDetailsState extends State<LivestreamsDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeSlide =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(String label) {
    debugPrint("Admin Action: $label");
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(_fadeSlide),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Live Streaming Control",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white54),
                    onPressed: () => _onItemTap("Streaming Settings"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// STREAM HEALTH
              Center(
                child: CircularPercentIndicator(
                  radius: 85,
                  lineWidth: 10,
                  percent: 0.78,
                  animation: true,
                  animationDuration: 900,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "78%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Stream Health",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.grey.shade800,
                  progressColor: Colors.greenAccent,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),

              const SizedBox(height: 24),

              /// LIVE STREAM METRICS
              _SidebarItem(
                icon: Icons.live_tv,
                color: Colors.redAccent,
                title: "Active Live Streams",
                subtitle: "12 currently broadcasting",
                onTap: () => _onItemTap("Active Live Streams"),
              ),
              _SidebarItem(
                icon: Icons.people_alt_rounded,
                color: Colors.blueAccent,
                title: "Total Viewers",
                subtitle: "8.4K watching now",
                onTap: () => _onItemTap("Total Viewers"),
              ),
              _SidebarItem(
                icon: Icons.shield_rounded,
                color: Colors.orangeAccent,
                title: "Moderation Queue",
                subtitle: "5 reports pending",
                onTap: () => _onItemTap("Moderation Queue"),
              ),
              _SidebarItem(
                icon: Icons.attach_money_rounded,
                color: Colors.greenAccent,
                title: "Live Gifts & Revenue",
                subtitle: "₦245,300 today",
                onTap: () => _onItemTap("Live Revenue"),
              ),

              const SizedBox(height: 18),

              /// ADMIN QUICK ACTIONS
              const Text(
                "Admin Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionChip(
                    label: "End Stream",
                    icon: Icons.stop_circle,
                    onTap: () => _onItemTap("End Stream"),
                  ),
                  _ActionChip(
                    label: "Suspend User",
                    icon: Icons.block,
                    onTap: () => _onItemTap("Suspend User"),
                  ),
                  _ActionChip(
                    label: "Review Reports",
                    icon: Icons.report,
                    onTap: () => _onItemTap("Review Reports"),
                  ),
                  _ActionChip(
                    label: "Stream Logs",
                    icon: Icons.receipt_long,
                    onTap: () => _onItemTap("Stream Logs"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SubscriptionDetails extends StatefulWidget {
  const SubscriptionDetails({super.key});

  @override
  State<SubscriptionDetails> createState() => _SubscriptionDetailsState();
}

class _SubscriptionDetailsState extends State<SubscriptionDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeSlide =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(String label) {
    debugPrint("Subscription Action: $label");
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(_fadeSlide),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2C2F4A),
                Color(0xFF1F2233),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Subscriptions & Revenue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white60),
                    onPressed: () => _onItemTap("Subscription Settings"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// REVENUE HEALTH
              Center(
                child: CircularPercentIndicator(
                  radius: 80,
                  lineWidth: 10,
                  percent: 0.72,
                  animation: true,
                  animationDuration: 900,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "72%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Revenue Health",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.grey.shade800,
                  progressColor: Colors.purpleAccent,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),

              const SizedBox(height: 24),

              /// SUBSCRIPTION METRICS
              _SubscriptionItem(
                icon: Icons.people_alt_rounded,
                color: Colors.blueAccent,
                title: "Active Subscribers",
                subtitle: "3,482 users",
                onTap: () => _onItemTap("Active Subscribers"),
              ),
              _SubscriptionItem(
                icon: Icons.star_rounded,
                color: Colors.amberAccent,
                title: "Premium Plans",
                subtitle: "Gold & Creator tiers",
                onTap: () => _onItemTap("Premium Plans"),
              ),
              _SubscriptionItem(
                icon: Icons.autorenew_rounded,
                color: Colors.greenAccent,
                title: "Auto Renewals",
                subtitle: "89% enabled",
                onTap: () => _onItemTap("Auto Renewals"),
              ),
              _SubscriptionItem(
                icon: Icons.trending_down_rounded,
                color: Colors.redAccent,
                title: "Churn Rate",
                subtitle: "4.2% this month",
                onTap: () => _onItemTap("Churn Rate"),
              ),

              const SizedBox(height: 18),

              /// ADMIN ACTIONS
              const Text(
                "Subscription Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SubscriptionActionChip(
                    label: "Create Plan",
                    icon: Icons.add_circle_outline,
                    onTap: () => _onItemTap("Create Plan"),
                  ),
                  _SubscriptionActionChip(
                    label: "Manage Pricing",
                    icon: Icons.attach_money,
                    onTap: () => _onItemTap("Manage Pricing"),
                  ),
                  _SubscriptionActionChip(
                    label: "Promo Codes",
                    icon: Icons.local_offer,
                    onTap: () => _onItemTap("Promo Codes"),
                  ),
                  _SubscriptionActionChip(
                    label: "Billing Logs",
                    icon: Icons.receipt_long,
                    onTap: () => _onItemTap("Billing Logs"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SubscriptionItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}



class _SubscriptionActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SubscriptionActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class ReportsPolicyDetails extends StatefulWidget {
  const ReportsPolicyDetails({super.key});

  @override
  State<ReportsPolicyDetails> createState() => _ReportsPolicyDetailsState();
}

class _ReportsPolicyDetailsState extends State<ReportsPolicyDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeSlide =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(String label) {
    debugPrint("Policy Action: $label");
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(_fadeSlide),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF332A2A),
                Color(0xFF1F1C1C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Reports & Policy",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.policy, color: Colors.white60),
                    onPressed: () => _onItemTap("Policy Settings"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// COMPLIANCE HEALTH
              Center(
                child: CircularPercentIndicator(
                  radius: 80,
                  lineWidth: 10,
                  percent: 0.91,
                  animation: true,
                  animationDuration: 900,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "91%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Policy Compliance",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.grey.shade800,
                  progressColor: Colors.redAccent,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),

              const SizedBox(height: 24),

              /// REPORT METRICS
              _PolicyItem(
                icon: Icons.report_problem_rounded,
                color: Colors.orangeAccent,
                title: "Pending Reports",
                subtitle: "14 awaiting review",
                onTap: () => _onItemTap("Pending Reports"),
              ),
              _PolicyItem(
                icon: Icons.verified_rounded,
                color: Colors.greenAccent,
                title: "Resolved Cases",
                subtitle: "1,284 total",
                onTap: () => _onItemTap("Resolved Cases"),
              ),
              _PolicyItem(
                icon: Icons.block_rounded,
                color: Colors.redAccent,
                title: "Suspended Accounts",
                subtitle: "32 active bans",
                onTap: () => _onItemTap("Suspended Accounts"),
              ),
              _PolicyItem(
                icon: Icons.gavel_rounded,
                color: Colors.purpleAccent,
                title: "Policy Violations",
                subtitle: "Content & behavior",
                onTap: () => _onItemTap("Policy Violations"),
              ),

              const SizedBox(height: 18),

              /// ADMIN ENFORCEMENT ACTIONS
              const Text(
                "Enforcement Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _PolicyActionChip(
                    label: "Review Reports",
                    icon: Icons.fact_check,
                    onTap: () => _onItemTap("Review Reports"),
                  ),
                  _PolicyActionChip(
                    label: "Update Policy",
                    icon: Icons.edit_document,
                    onTap: () => _onItemTap("Update Policy"),
                  ),
                  _PolicyActionChip(
                    label: "Ban User",
                    icon: Icons.person_off,
                    onTap: () => _onItemTap("Ban User"),
                  ),
                  _PolicyActionChip(
                    label: "Appeal Logs",
                    icon: Icons.receipt_long,
                    onTap: () => _onItemTap("Appeal Logs"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PolicyItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}


class _PolicyActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PolicyActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
