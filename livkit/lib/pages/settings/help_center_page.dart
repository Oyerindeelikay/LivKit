import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(
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
        title: const Text("Help Center", style: TextStyle(color: Colors.white)),
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
              width: isDesktop ? 700 : double.infinity,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _supportCard(),
                  const SizedBox(height: 25),
                  _sectionTitle("Get Help"),
                  _helpTile(
                    icon: Icons.report_problem,
                    color: Colors.orangeAccent,
                    title: "Report a Problem",
                    subtitle: "Something isn’t working correctly",
                    onTap: () => _openReportForm(),
                  ),
                  _helpTile(
                    icon: Icons.bug_report,
                    color: Colors.redAccent,
                    title: "Submit a Complaint",
                    subtitle: "Report abuse, bugs, or policy issues",
                    onTap: () => _openReportForm(),
                  ),
                  _helpTile(
                    icon: Icons.payment,
                    color: Colors.greenAccent,
                    title: "Payments & Earnings",
                    subtitle: "Issues with gifts, payouts, or subscriptions",
                    onTap: () => _openReportForm(),
                  ),
                  const SizedBox(height: 30),
                  _sectionTitle("Resources"),
                  _helpTile(
                    icon: Icons.help_outline,
                    color: Colors.blueAccent,
                    title: "FAQs",
                    subtitle: "Frequently asked questions",
                    onTap: () => _openFAQs(),
                  ),
                  _helpTile(
                    icon: Icons.security,
                    color: Colors.purpleAccent,
                    title: "Safety & Policies",
                    subtitle: "Community guidelines & safety tips",
                    onTap: () => _openPolicies(),
                  ),
                  _helpTile(
                    icon: Icons.contact_support,
                    color: Colors.cyanAccent,
                    title: "Contact Support",
                    subtitle: "Reach out to our support team",
                    onTap: () => _openContact(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= SUPPORT CARD =================

  Widget _supportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent, color: Colors.greenAccent, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "Our support team typically responds within 24 hours.",
              style: TextStyle(color: Colors.white70),
            ),
          ),
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
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _helpTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
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
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  // ================= POPUPS =================

  void _openPopup(Widget child) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => child,
      transitionBuilder: (_, anim, __, child) {
        return Transform.translate(
          offset: Offset(0, (1 - anim.value) * 60),
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  // ================= REPORT FORM =================

  void _openReportForm() {
    String selected = "Report a problem";

    _openPopup(
      _popupScaffold(
        title: "Submit Report",
        child: StatefulBuilder(
          builder: (context, setModal) {
            return Column(
              children: [
                _dropdown(
                  value: selected,
                  items: const [
                    "Report a problem",
                    "Log a bug complaint",
                    "Payment issues"
                  ],
                  onChanged: (v) => setModal(() => selected = v!),
                ),
                _input("Title"),
                _input("Describe the issue", maxLines: 4),
                const SizedBox(height: 20),
                _primaryButton("Submit Report"),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= FAQs =================

  void _openFAQs() {
    _openPopup(
      _popupScaffold(
        title: "Frequently Asked Questions",
        child: Column(
          children: [
            _faq("How do I earn on Livkit?",
                "You earn through gifts, subscriptions, and viewer engagement during live streams."),
            _faq("When do payouts occur?",
                "Payouts are processed weekly once you reach the minimum threshold."),
            _faq("Can viewers send gifts?",
                "Yes, viewers can purchase and send virtual gifts during live sessions."),
            _faq("What content is not allowed?",
                "Hate speech, explicit content, fraud, or harassment is strictly prohibited."),
            _faq("How do I report abuse?",
                "Use the Report option in Help Center or directly from the live stream."),
            _faq("Is my payment information secure?",
                "Yes, Livkit uses industry-standard encryption and security protocols."),
            _faq("Can I stream from any country?",
                "Livkit supports creators globally, subject to local regulations."),
          ],
        ),
      ),
    );
  }

  // ================= POLICIES =================

  void _openPolicies() {
    _openPopup(
      _popupScaffold(
        title: "Livkit Safety & Policies",
        child: const Text(
          "Livkit is committed to providing a safe, inclusive, and rewarding "
          "live streaming environment.\n\n"
          "• Creators must respect community standards and local laws.\n"
          "• Monetization abuse, scams, or manipulation are prohibited.\n"
          "• Viewers must not harass, threaten, or exploit creators.\n"
          "• Payments and earnings are monitored to prevent fraud.\n"
          "• Violations may result in suspension or permanent bans.\n\n"
          "By using Livkit, you agree to uphold these standards.",
          style: TextStyle(color: Colors.white70, height: 1.6),
        ),
      ),
    );
  }

  // ================= CONTACT =================

  void _openContact() {
    _openPopup(
      _popupScaffold(
        title: "Contact Support",
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: support@livkit.app",
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text("Phone: +1 555 234 8899",
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text("Address: 123 Livkit Street, Streaming City",
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // ================= SHARED UI =================

  Widget _popupScaffold({required String title, required Widget child}) {
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
                padding: const EdgeInsets.only(top: 30),
                child: SingleChildScrollView(child: child),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: Colors.black87,
        isExpanded: true,
        underline: const SizedBox(),
        iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _faq(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(color: Colors.white)),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child:
              Text(a, style: const TextStyle(color: Colors.white70, height: 1.5)),
        )
      ],
    );
  }
}
