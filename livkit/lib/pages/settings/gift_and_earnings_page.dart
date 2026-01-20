import 'package:flutter/material.dart';

class GiftsEarningsPage extends StatefulWidget {
  const GiftsEarningsPage({super.key});

  @override
  State<GiftsEarningsPage> createState() => _GiftsEarningsPageState();
}

class _GiftsEarningsPageState extends State<GiftsEarningsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
        title: const Text("Gifts & Earnings", style: TextStyle(color: Colors.white)),
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
                        Expanded(flex: 3, child: _earningsDetails()),
                      ],
                    )
                  : ListView(
                      children: [
                        _statsSection(),
                        const SizedBox(height: 25),
                        _earningsDetails(),
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
          "Earnings Overview",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: const [
            _EarningCard(
              title: "Available Balance",
              value: "₦124,500",
              accent: Colors.greenAccent,
            ),
            _EarningCard(
              title: "Total Earnings",
              value: "₦540,200",
              accent: Colors.blueAccent,
            ),
            _EarningCard(
              title: "Pending Earnings",
              value: "₦38,000",
              accent: Colors.orangeAccent,
            ),
            _EarningCard(
              title: "Withdrawn",
              value: "₦377,700",
              accent: Colors.purpleAccent,
            ),
            _EarningCard(
              title: "Total Views",
              value: "1.2M",
              accent: Colors.cyanAccent,
            ),
            _EarningCard(
              title: "Total Gifts",
              value: "9,420",
              accent: Colors.redAccent,
            ),
          ],
        ),
      ],
    );
  }

  // ================== DETAILS ==================

  Widget _earningsDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _withdrawCard(),
        const SizedBox(height: 25),
        _topFansSection(),
        const SizedBox(height: 25),
        _recentGiftsSection(),
      ],
    );
  }

  Widget _withdrawCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Withdraw Earnings",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            "Withdraw your available balance to your bank account.",
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              child: const Text("Withdraw Now"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topFansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Top Gifting Fans",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _fanItem("Alex", "₦45,000"),
        _fanItem("Precious", "₦32,800"),
        _fanItem("Daniel", "₦21,500"),
      ],
    );
  }

  Widget _fanItem(String name, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: const TextStyle(color: Colors.white)),
          ),
          Text(amount,
              style: const TextStyle(
                  color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _recentGiftsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Gifts",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _giftItem("Rose x5", "Alex", "₦2,500"),
        _giftItem("Lion x1", "Daniel", "₦10,000"),
        _giftItem("Galaxy x1", "Precious", "₦25,000"),
      ],
    );
  }

  Widget _giftItem(String gift, String from, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text("$gift from $from",
                style: const TextStyle(color: Colors.white)),
          ),
          Text(amount,
              style: const TextStyle(
                  color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ================== CARD ==================

class _EarningCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _EarningCard({
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
