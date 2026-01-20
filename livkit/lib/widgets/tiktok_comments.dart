import 'package:flutter/material.dart';
import 'dart:async';

/// 🎮 Public controller (SAFE access)
class TikTokCommentsController {
  void Function(String message)? _add;

  void addComment(String message) {
    _add?.call(message);
  }
}

class TikTokComments extends StatefulWidget {
  final TikTokCommentsController controller;

  const TikTokComments({
    super.key,
    required this.controller,
  });

  @override
  State<TikTokComments> createState() => _TikTokCommentsState();
}

class _TikTokCommentsState extends State<TikTokComments> {
  final List<Map<String, String>> _allComments = [
    {'user': 'user01', 'msg': '🔥🔥🔥'},
    {'user': 'user02', 'msg': 'Love this ❤️'},
    {'user': 'user03', 'msg': 'Go off 👏🏽'},
    {'user': 'join', 'msg': '@bliss_22 joined the live'},
    {'user': 'user04', 'msg': '😂😂😂'},
  ];

  final List<Map<String, String>> visible = [];
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    /// 🔗 Bind controller to state method
    widget.controller._add = (message) {
      setState(() {
        visible.insert(0, {'user': 'You', 'msg': message});
        if (visible.length > 6) visible.removeLast();
      });
    };

    timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      setState(() {
        visible.insert(0, _allComments[index]);
        if (visible.length > 6) visible.removeLast();
        index = (index + 1) % _allComments.length;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140,
      left: 10,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: visible.map((c) {
            final isJoin = c['user'] == 'join';
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                isJoin ? c['msg']! : "${c['user']}: ${c['msg']}",
                style: TextStyle(
                  color: isJoin ? Colors.greenAccent : Colors.white,
                  fontSize: 14,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
