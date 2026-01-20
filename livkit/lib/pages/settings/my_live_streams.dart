import 'package:flutter/material.dart';

class MyLiveStreamsPage extends StatefulWidget {
  const MyLiveStreamsPage({super.key});

  @override
  State<MyLiveStreamsPage> createState() => _MyLiveStreamsPageState();
}

class _MyLiveStreamsPageState extends State<MyLiveStreamsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
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
          "My Live Streams",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _statsSection()),
                        const SizedBox(width: 20),
                        Expanded(flex: 3, child: _streamsList()),
                      ],
                    )
                  : ListView(
                      children: [
                        _statsSection(),
                        const SizedBox(height: 25),
                        _streamsList(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== STATS ==================

  Widget _statsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Live Summary",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: const [
            _LiveStatCard(
              title: "Total Streams",
              value: "86",
              accent: Colors.blueAccent,
            ),
            _LiveStatCard(
              title: "Hours Streamed",
              value: "214h",
              accent: Colors.purpleAccent,
            ),
            _LiveStatCard(
              title: "Peak Viewers",
              value: "15.6K",
              accent: Colors.orangeAccent,
            ),
            _LiveStatCard(
              title: "Total Likes",
              value: "345K",
              accent: Colors.pinkAccent,
            ),
          ],
        ),
      ],
    );
  }

  // ================== STREAMS ==================

  Widget _streamsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stream History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        _streamItem(
          title: "Late Night Chat 💬",
          date: "Dec 12, 2025",
          duration: "2h 14m",
          viewers: "12.4K",
          likes: "18.2K",
          status: "Ended",
        ),
        _streamItem(
          title: "Music & Chill 🎵",
          date: "Dec 10, 2025",
          duration: "1h 40m",
          viewers: "8.1K",
          likes: "9.7K",
          status: "Ended",
        ),
        _streamItem(
          title: "Ask Me Anything 🔥",
          date: "Dec 08, 2025",
          duration: "2h 55m",
          viewers: "15.6K",
          likes: "25.4K",
          status: "Ended",
        ),
      ],
    );
  }

  Widget _streamItem({
    required String title,
    required String date,
    required String duration,
    required String viewers,
    required String likes,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.live_tv, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  "$date • $duration",
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _meta(Icons.remove_red_eye, viewers),
                    const SizedBox(width: 12),
                    _meta(Icons.favorite, likes),
                  ],
                ),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white38)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ================== STAT CARD ==================

class _LiveStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _LiveStatCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accent, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
