import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: mark all as read
            },
            child: const Text(
              "Mark all",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isDesktop
                  ? Center(
                      child: SizedBox(
                        width: 700,
                        child: _notificationList(),
                      ),
                    )
                  : _notificationList(),
            ),
          ),
        ),
      ),
    );
  }

  // ================= LIST =================

  Widget _notificationList() {
    return ListView(
      children: [
        _sectionTitle("Today"),
        _notificationTile(
          icon: Icons.live_tv,
          color: Colors.redAccent,
          title: "Live Stream Reminder",
          subtitle: "You went live and gained 120 new viewers",
          time: "5m ago",
          unread: true,
        ),
        _notificationTile(
          icon: Icons.card_giftcard,
          color: Colors.purpleAccent,
          title: "New Gift Received",
          subtitle: "A viewer sent you a Galaxy gift 🎁",
          time: "25m ago",
          unread: true,
        ),

        const SizedBox(height: 20),
        _sectionTitle("Earlier"),
        _notificationTile(
          icon: Icons.people,
          color: Colors.blueAccent,
          title: "New Subscriber",
          subtitle: "John subscribed to your channel",
          time: "Yesterday",
        ),
        _notificationTile(
          icon: Icons.trending_up,
          color: Colors.greenAccent,
          title: "Earnings Update",
          subtitle: "You earned \$124 from live streams",
          time: "2 days ago",
        ),
        _notificationTile(
          icon: Icons.info_outline,
          color: Colors.orangeAccent,
          title: "System Update",
          subtitle: "New features added to live analytics",
          time: "3 days ago",
        ),
      ],
    );
  }

  // ================= COMPONENTS =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _notificationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    bool unread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread ? Colors.white12 : Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: unread
            ? Border(left: BorderSide(color: color, width: 4))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
