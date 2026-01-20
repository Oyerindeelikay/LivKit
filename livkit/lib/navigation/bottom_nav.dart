import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final Function(int) onTap;
  final int selected;

  const BottomNav({
    super.key,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(Icons.home_outlined, "Home", 0),

          // 📡 Live (broadcast icon)
          navItem(Icons.wifi_tethering_outlined, "Live", 1),

          // ➕ Center Create Button
          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),

          // 📄 Page
          navItem(Icons.chat_bubble_outline, "Chat", 3),

          // 👤 Profile
          navItem(Icons.person_outline, "Profile", 4),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final bool active = selected == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: active ? Colors.white : Colors.white70,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
