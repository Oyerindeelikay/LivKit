import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("About", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: SizedBox(
              width: isDesktop ? 650 : double.infinity,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _appHeader(),
                  const SizedBox(height: 30),
                  _infoCard(
                    title: "About the App",
                    content:
                        "LiveKit is a modern live-streaming platform designed "
                        "to connect creators and audiences in real time. "
                        "Stream, engage, and earn through interactive features "
                        "and viewer monetization.",
                  ),
                  const SizedBox(height: 20),
                  _infoCard(
                    title: "Version",
                    content: "LiveKit v1.0.0 (Build 100)",
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle("Legal"),
                  _linkTile(
                    icon: Icons.description,
                    title: "Terms of Service",
                    onTap: _openTerms,
                  ),
                  _linkTile(
                    icon: Icons.privacy_tip,
                    title: "Privacy Policy",
                    onTap: _openPrivacy,
                  ),
                  _linkTile(
                    icon: Icons.gavel,
                    title: "Community Guidelines",
                    onTap: _openGuidelines,
                  ),
                  const SizedBox(height: 30),
                  _footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= POPUP BASE =================

  void _openPopup(String title, Widget content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: SingleChildScrollView(child: content),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return Transform.translate(
          offset: Offset(0, (1 - anim.value) * 60),
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  // ================= TERMS =================

  void _openTerms() {
    _openPopup(
      "Terms of Service",
      const Text(
        "Welcome to LiveKit.\n\n"
        "By accessing or using LiveKit, you agree to comply with these Terms of Service.\n\n"
        "• Users must be at least 18 years old or have parental consent.\n"
        "• Creators are responsible for all content streamed from their account.\n"
        "• Monetization features must not be abused, manipulated, or used fraudulently.\n"
        "• Prohibited content includes illegal activity, hate speech, explicit material, or scams.\n"
        "• LiveKit reserves the right to suspend or terminate accounts that violate these terms.\n\n"
        "LiveKit provides the platform \"as is\" and is not liable for user-generated content.",
        style: TextStyle(color: Colors.white70, height: 1.6),
      ),
    );
  }

  // ================= PRIVACY =================

  void _openPrivacy() {
    _openPopup(
      "Privacy Policy",
      const Text(
        "LiveKit respects your privacy and is committed to protecting your data.\n\n"
        "• We collect account information, usage data, and monetization activity.\n"
        "• Payment data is securely processed through trusted third-party providers.\n"
        "• Cookies and analytics help us improve performance and user experience.\n"
        "• We do not sell personal data to third parties.\n"
        "• Reasonable security measures are in place to protect user information.\n\n"
        "By using LiveKit, you consent to this Privacy Policy.",
        style: TextStyle(color: Colors.white70, height: 1.6),
      ),
    );
  }

  // ================= GUIDELINES =================

  void _openGuidelines() {
    _openPopup(
      "Community Guidelines",
      const Text(
        "LiveKit is a community built on respect and creativity.\n\n"
        "• Treat all users with respect and dignity.\n"
        "• Harassment, bullying, or hate speech is not tolerated.\n"
        "• Explicit, violent, or illegal content is prohibited.\n"
        "• Monetization abuse, fake engagement, or scams are strictly forbidden.\n"
        "• Violations may result in content removal, suspension, or permanent bans.\n\n"
        "Help us keep LiveKit safe and enjoyable for everyone.",
        style: TextStyle(color: Colors.white70, height: 1.6),
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _appHeader() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white12,
          child: Icon(Icons.live_tv, size: 40, color: Colors.redAccent),
        ),
        SizedBox(height: 14),
        Text("LiveKit",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text("Connect • Stream • Earn",
            style: TextStyle(color: Colors.white54)),
      ],
    );
  }

  Widget _infoCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _linkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(color: Colors.white)),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return const Center(
      child: Text(
        "© 2025 LiveKit Inc.",
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }
}
