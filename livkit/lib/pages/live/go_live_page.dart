import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';
import '../../services/streaming_service.dart';
import 'streamer_page.dart';
import '../settings/gift_and_earnings_page.dart';
import '../chat/chat_page.dart';

class GoLivePage extends StatefulWidget {
  final int roomId;
  final StreamingService streamingService;
  final String userToken; // ← add this

  const GoLivePage({
    super.key,
    required this.roomId,
    required this.streamingService,
    required this.userToken, // ← require it
  });

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}


class _GoLivePageState extends State<GoLivePage> {
  final TextEditingController _titleController = TextEditingController();

  late final StreamingService _streamingService;
  late final AuthService _authService;

  bool _loading = false;

  void _log(String msg) {
    if (kDebugMode) {
      debugPrint('🎬 [GoLivePage] $msg');
    }
  }

  @override
  void initState() {
    super.initState();

    _authService = AuthService();
    _streamingService = StreamingService(
      baseUrl: 'http://127.0.0.1:8000/api/streaming',
      getAuthToken: _authService.getAccessToken,
    );
  }

  // =========================
  // GO LIVE NOW
  // =========================
  Future<void> _goLiveNow() async {
    if (_loading) return;
    setState(() => _loading = true);

    _log('GO LIVE pressed');

    try {
      final joinData = await _streamingService.goLive(
        sessionId: 0, // backend should resolve active room for host
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StreamerPage(
            sessionId: joinData.sessionId,
            title: _titleController.text.trim().isEmpty
                ? 'Untitled Live'
                : _titleController.text.trim(),
            streamingService: _streamingService,
          ),
        ),
      );
    } catch (e, stack) {
      _log('ERROR: $e');
      _log(stack.toString());

      _snack('Failed to go live');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // =========================
  // SCHEDULE LIVE
  // =========================
  Future<void> _scheduleLive() async {
    _log('Schedule pressed');

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    try {
      await _streamingService.scheduleLive(
        roomId: 0, // backend decides room ownership
        scheduledStart: scheduledAt,
      );

      _snack('Live scheduled successfully');
      _log('Scheduled for $scheduledAt');
    } catch (e) {
      _log('Schedule error: $e');
      _snack('Failed to schedule live');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // =========================
  // UI (UNCHANGED)
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ───────── TOP BAR ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    'Go Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ───────── CAMERA PREVIEW ─────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: MediaQuery.of(context).size.height * 0.42,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.videocam, color: Colors.white54, size: 60),
              ),
            ),

            const SizedBox(height: 20),

            // ───────── TITLE ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                maxLength: 80,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Add a title for your live',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ───────── OPTIONS ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Option(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Coming Soon'),
                        content: const Text('This feature is not available yet.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _Option(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPageList(token: widget.userToken),

                      ),
                    );
                  },
                ),
                _Option(
                  icon: Icons.card_giftcard,
                  label: 'Gifts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftsEarningsPage(),
                      ),
                    );
                  },
                ),
                const _Option(icon: Icons.mic_none, label: 'Mic'),
              ],
            ),



            const Spacer(),

            // ───────── GO LIVE ─────────
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: _loading ? null : _goLiveNow,
                child: Container(
                  width: 240,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0050), Color(0xFFFF2E63)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text(
                            'GO LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────── OPTION WIDGET ─────────
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
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
