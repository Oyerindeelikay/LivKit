import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/live_service.dart';
import '../live/live_streaming_page.dart';

class GoLivePage extends StatefulWidget {
  const GoLivePage({super.key});

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  final LiveService _liveService = LiveService();
  final TextEditingController _titleController = TextEditingController();

  DateTime? _scheduledTime;
  bool _loading = false;

  bool get _isScheduled => _scheduledTime != null;

  // ─────────────────────────────────────────────
  // CREATE / START LIVE
  // ─────────────────────────────────────────────
  Future<void> _handleGoLive() async {
    if (_loading) return;

    final title = _titleController.text.trim().isEmpty
        ? "Untitled Live"
        : _titleController.text.trim();

    setState(() => _loading = true);

    try {
      final created = await _liveService.createLiveStream(
        title: title,
        scheduledAt: _scheduledTime?.toIso8601String(),
      );

      // Use streamId as String (UUID)
      final String streamId = created["id"].toString();

      if (!_isScheduled) {
        // 🚀 Start live immediately
        final started = await _liveService.startLiveStream(streamId);

        final token = started["agora_token"];
        final channel = started["agora_channel"];
        final uid = started["uid"];

        if (token == null || channel == null || uid == null) {
          throw Exception(
              "Backend did not return valid Agora credentials: $started");
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LiveStreamingPage(
              streamId: streamId,
              title: title,
              isHost: true,
              agoraToken: token,
              channelName: channel,
              uid: uid,
            ),
          ),
        );

      } else {
        _showSnack("Live scheduled successfully");
      }
    } catch (e) {
      debugPrint("GoLive error: $e");
      _showSnack("Failed to start live stream: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────
  // PICK SCHEDULE TIME
  // ─────────────────────────────────────────────
  Future<void> _pickScheduleTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ─────────────────────────────────────────────
  // SHARE LINK
  // ─────────────────────────────────────────────
  void _shareLink() {
    final link = "https://yourapp.com/live"; // replace with real deep link later
    Clipboard.setData(ClipboardData(text: link));
    _showSnack("Live link copied");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }



  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const SizedBox(height: 12),
            _cameraPreview(),
            const SizedBox(height: 18),
            _titleInput(),
            const SizedBox(height: 14),
            _optionsRow(),
            if (_isScheduled) _scheduleChip(),
            const Spacer(),
            _goLiveButton(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          BackButton(color: Colors.white),
          Spacer(),
          Text(
            "Go Live",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _cameraPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: MediaQuery.of(context).size.height * 0.42,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white54, size: 60),
      ),
    );
  }

  Widget _titleInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _titleController,
        maxLength: 80,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          counterText: "",
          hintText: "Add a title for your live",
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _optionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Option(icon: Icons.schedule, label: "Schedule", onTap: _pickScheduleTime),
        _Option(icon: Icons.share, label: "Share", onTap: _shareLink),
        const _Option(icon: Icons.chat_bubble_outline, label: "Chat"),
        const _Option(icon: Icons.card_giftcard, label: "Gifts"),
      ],
    );
  }

  Widget _scheduleChip() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Chip(
        backgroundColor: Colors.pinkAccent,
        label: Text(
          "Scheduled: ${_scheduledTime!.toLocal()}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _goLiveButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: _loading ? null : _handleGoLive,
        child: Container(
          width: 240,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF0050), Color(0xFFFF2E63)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _isScheduled ? "SCHEDULE LIVE" : "GO LIVE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OPTION WIDGET
// ─────────────────────────────────────────────
class _Option extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _Option({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white12,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
