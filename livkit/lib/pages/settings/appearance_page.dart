import 'package:flutter/material.dart';

enum ThemeModeOption { system, dark, light }

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  ThemeModeOption _selectedMode = ThemeModeOption.dark;
  Color _accentColor = Colors.blueAccent;

  final List<Color> _accentColors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
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
          "Appearance",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: SizedBox(
                width: isDesktop ? 650 : double.infinity,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle("Theme Mode"),
                    _themeOption(
                      title: "System Default",
                      value: ThemeModeOption.system,
                      icon: Icons.settings_suggest,
                    ),
                    _themeOption(
                      title: "Dark Mode",
                      value: ThemeModeOption.dark,
                      icon: Icons.dark_mode,
                    ),
                    _themeOption(
                      title: "Light Mode",
                      value: ThemeModeOption.light,
                      icon: Icons.light_mode,
                    ),

                    const SizedBox(height: 25),

                    _sectionTitle("Accent Color"),
                    _accentColorSelector(),

                    const SizedBox(height: 25),

                    _sectionTitle("Preview"),
                    _previewCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================

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

  // ================= THEME OPTION =================

  Widget _themeOption({
    required String title,
    required ThemeModeOption value,
    required IconData icon,
  }) {
    final bool selected = _selectedMode == value;

    return InkWell(
      onTap: () {
        setState(() => _selectedMode = value);

        // TODO: Persist theme & rebuild app
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white12 : Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: _accentColor, width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? _accentColor : Colors.white54),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? _accentColor : Colors.white,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: _accentColor),
          ],
        ),
      ),
    );
  }

  // ================= ACCENT COLOR =================

  Widget _accentColorSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _accentColors.map((color) {
          final bool selected = _accentColor == color;
          return GestureDetector(
            onTap: () {
              setState(() => _accentColor = color);
              // TODO: persist accent color
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= PREVIEW =================

  Widget _previewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications, color: _accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "This is a preview of your selected appearance settings.",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
