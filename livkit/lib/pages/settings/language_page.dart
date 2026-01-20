import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String _selectedLanguage = "English";

  final List<String> _languages = [
    "English",
    "French",
    "Spanish",
    "German",
    "Portuguese",
    "Arabic",
    "Hindi",
    "Chinese (Simplified)",
    "Chinese (Traditional)",
    "Japanese",
    "Korean",
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
          "Language",
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
                width: isDesktop ? 600 : double.infinity,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _infoCard(),
                    const SizedBox(height: 20),
                    ..._languages.map(_languageTile).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= INFO =================

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        "Choose your preferred language. The app will restart automatically "
        "to apply changes.",
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  // ================= LANGUAGE TILE =================

  Widget _languageTile(String language) {
    final bool selected = _selectedLanguage == language;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });

        // TODO: Save language preference & reload app
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$language coming soon"),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.blueAccent.withOpacity(0.15) : Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: Colors.blueAccent, width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  color: selected ? Colors.blueAccent : Colors.white,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.blueAccent,
              ),
          ],
        ),
      ),
    );
  }
}
