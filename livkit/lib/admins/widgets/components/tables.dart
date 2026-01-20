import 'package:flutter/material.dart';
import '../constants.dart';

class AdminsActivityTable extends StatefulWidget {
  const AdminsActivityTable({super.key});

  @override
  State<AdminsActivityTable> createState() => _AdminsActivityTableState();
}

class _AdminsActivityTableState extends State<AdminsActivityTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  final List<Map<String, dynamic>> activities = [
    {
      "title": "Live stream started",
      "user": "creator_ella",
      "time": "2 mins ago",
      "icon": Icons.videocam,
      "color": Colors.greenAccent,
    },
    {
      "title": "Content flagged",
      "user": "stream_8921",
      "time": "10 mins ago",
      "icon": Icons.flag,
      "color": Colors.redAccent,
    },
    {
      "title": "Stream ended",
      "user": "creator_jay",
      "time": "18 mins ago",
      "icon": Icons.stop_circle,
      "color": Colors.orangeAccent,
    },
    {
      "title": "New creator verified",
      "user": "creator_sam",
      "time": "30 mins ago",
      "icon": Icons.verified,
      "color": Colors.blueAccent,
    },
    {
      "title": "Policy warning issued",
      "user": "stream_442",
      "time": "1 hr ago",
      "icon": Icons.warning_amber_rounded,
      "color": Colors.purpleAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeSlide =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRowTap(Map<String, dynamic> item) {
    // Hook into details page / dialog later
    debugPrint("Clicked activity: ${item['title']}");
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Platform Activity",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          /// TABLE CONTAINER
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const _TableHeader(),
                ...activities.take(4).map(
                  (activity) => _ActivityRow(
                    data: activity,
                    onTap: () => _onRowTap(activity),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullActivityPage(activities: activities),
                      ),
                    );
                  },
                  child: const Text(
                    "View All Activity",
                    style: TextStyle(color: Colors.blueAccent),
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



class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("Event", style: TextStyle(color: Colors.white54))),
          Expanded(flex: 2, child: Text("Target", style: TextStyle(color: Colors.white54))),
          Expanded(flex: 2, child: Text("Time", style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }
}



class _ActivityRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ActivityRow({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: data['color'].withOpacity(0.15),
                    child: Icon(
                      data['icon'],
                      color: data['color'],
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      data['title'],
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                data['user'],
                style: TextStyle(color: Colors.grey.shade300),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                data['time'],
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FullActivityPage extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const FullActivityPage({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Platform Activity Log"),
        backgroundColor: const Color(0xFF2A2D3E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: activities
            .map((activity) => _ActivityRow(
                  data: activity,
                  onTap: () {},
                ))
            .toList(),
      ),
    );
  }
}












class LiveStreamControlQueue extends StatefulWidget {
  const LiveStreamControlQueue({super.key});

  @override
  State<LiveStreamControlQueue> createState() =>
      _LiveStreamControlQueueState();
}

class _LiveStreamControlQueueState extends State<LiveStreamControlQueue>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  final List<Map<String, dynamic>> liveStreams = [
    {
      "creator": "ella_live",
      "category": "Music",
      "viewers": "2.3K",
      "status": "Healthy",
      "risk": Colors.greenAccent,
    },
    {
      "creator": "jay_tv",
      "category": "Just Chatting",
      "viewers": "5.1K",
      "status": "High Load",
      "risk": Colors.orangeAccent,
    },
    {
      "creator": "sam_stream",
      "category": "Gaming",
      "viewers": "1.8K",
      "status": "Flagged",
      "risk": Colors.redAccent,
    },
    {
      "creator": "mike_live",
      "category": "Sports",
      "viewers": "3.2K",
      "status": "Healthy",
      "risk": Colors.greenAccent,
    },
    {
      "creator": "lisa_stream",
      "category": "Music",
      "viewers": "4.0K",
      "status": "High Load",
      "risk": Colors.orangeAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeSlide = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAction(String action, String creator) {
    debugPrint("$action pressed for $creator");
  }

  void _openFullReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullLiveStreamReportPage(liveStreams: liveStreams),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Stream Control Queue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          /// TABLE CONTAINER
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const _QueueHeader(),
                ...liveStreams.take(3).map(
                  (stream) => _QueueRow(
                    data: stream,
                    onInspect: () => _onAction("Inspect", stream['creator']),
                    onMute: () => _onAction("Mute", stream['creator']),
                    onEnd: () => _onAction("End", stream['creator']),
                  ),
                ),
                TextButton(
                  onPressed: _openFullReport,
                  child: const Text(
                    "View Full Queue",
                    style: TextStyle(color: Colors.blueAccent),
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

/// ---------------- FULL REPORT PAGE ----------------
class FullLiveStreamReportPage extends StatelessWidget {
  final List<Map<String, dynamic>> liveStreams;

  const FullLiveStreamReportPage({super.key, required this.liveStreams});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F2E),
      appBar: AppBar(
        title: const Text("Full Live Stream Queue"),
        backgroundColor: const Color(0xFF2A2D3E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: liveStreams
            .map(
              (stream) => _QueueRow(
                data: stream,
                onInspect: () {},
                onMute: () {},
                onEnd: () {},
              ),
            )
            .toList(),
      ),
    );
  }
}




class _QueueHeader extends StatelessWidget {
  const _QueueHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("Creator", style: TextStyle(color: Colors.white54))),
          Expanded(flex: 2, child: Text("Category", style: TextStyle(color: Colors.white54))),
          Expanded(flex: 1, child: Text("Viewers", style: TextStyle(color: Colors.white54))),
          Expanded(flex: 2, child: Text("Status", style: TextStyle(color: Colors.white54))),
          Expanded(flex: 3, child: Text("Actions", style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onInspect;
  final VoidCallback onMute;
  final VoidCallback onEnd;

  const _QueueRow({
    required this.data,
    required this.onInspect,
    required this.onMute,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              data['creator'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data['category'],
              style: TextStyle(color: Colors.grey.shade300),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              data['viewers'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: data['risk'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  data['status'],
                  style: TextStyle(color: data['risk']),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _ActionBtn(
                  label: "Inspect",
                  color: Colors.blueAccent,
                  onTap: onInspect,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: "Mute",
                  color: Colors.orangeAccent,
                  onTap: onMute,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: "End",
                  color: Colors.redAccent,
                  onTap: onEnd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}













class AdminsTable extends StatefulWidget {
  const AdminsTable({super.key});

  @override
  State<AdminsTable> createState() => _AdminsTableState();
}

class _AdminsTableState extends State<AdminsTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  final List<Map<String, dynamic>> admins = [
    {
      "name": "Richard Niyi",
      "email": "richard@admin.com",
      "role": "Main Admin",
    },
    {
      "name": "Sarah Johnson",
      "email": "sarah@admin.com",
      "role": "Limited Admin",
    },
    {
      "name": "Michael Lee",
      "email": "michael@admin.com",
      "role": "Limited Admin",
    },
    {
      "name": "Admin Support",
      "email": "support@admin.com",
      "role": "Main Admin",
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeSlide =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEdit(Map<String, dynamic> admin) {
    debugPrint("Edit admin: ${admin['email']}");
  }

  void _onDelete(Map<String, dynamic> admin) {
    debugPrint("Delete admin: ${admin['email']}");
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Admins Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          /// TABLE CONTAINER
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const _AdminsTableHeader(),
                ...admins.take(3).map(
                  (admin) => _AdminRow(
                    data: admin,
                    onEdit: () => _onEdit(admin),
                    onDelete: () => _onDelete(admin),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullAdminsPage(admins: admins),
                      ),
                    );
                  },
                  child: const Text(
                    "View All Admins",
                    style: TextStyle(color: Colors.blueAccent),
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



class _AdminsTableHeader extends StatelessWidget {
  const _AdminsTableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text("Admin", style: TextStyle(color: Colors.white54)),
          ),
          Expanded(
            flex: 2,
            child: Text("Role", style: TextStyle(color: Colors.white54)),
          ),
          Expanded(
            flex: 1,
            child: Text("Actions", style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}





class _AdminRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminRow({
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMainAdmin = data['role'] == "Main Admin";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          /// ADMIN INFO
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data['email'],
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          /// ROLE
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isMainAdmin
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data['role'],
                style: TextStyle(
                  color: isMainAdmin ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          /// ACTIONS
          Expanded(
            flex: 1,
            child: PopupMenuButton<String>(
              color: const Color(0xFF2A2D3E),
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == "edit") onEdit();
                if (value == "delete") onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "edit",
                  child: Text("Edit"),
                ),
                PopupMenuItem(
                  value: "delete",
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.redAccent),
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






class FullAdminsPage extends StatelessWidget {
  final List<Map<String, dynamic>> admins;

  const FullAdminsPage({super.key, required this.admins});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("All Admins"),
        backgroundColor: const Color(0xFF2A2D3E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: admins
            .map(
              (admin) => _AdminRow(
                data: admin,
                onEdit: () {},
                onDelete: () {},
              ),
            )
            .toList(),
      ),
    );
  }
}
