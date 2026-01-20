import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


import '../constants.dart';


/// ---------------- LIVE STREAMING ANALYSIS ----------------

class LiveStreamAnalysis extends StatelessWidget {
  const LiveStreamAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "User Live Streaming Analytics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Duration Selector
          Row(
            children: [
              const Text(
                "Duration: ",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              DropdownButton<String>(
                dropdownColor: const Color(0xFF1E1F2E),
                value: "Day",
                items: <String>["Day", "Week", "Month", "Year"]
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  // Handle duration selection
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Analytics Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _AnalyticsCircle(
                percent: 0.61,
                label: "Server Load",
                color: Colors.greenAccent,
              ),
              _AnalyticsCircle(
                percent: 0.78,
                label: "Active Streams",
                color: Colors.blueAccent,
              ),
              _AnalyticsCircle(
                percent: 0.45,
                label: "Total Viewers",
                color: Colors.orangeAccent,
              ),
              _AnalyticsCircle(
                percent: 0.92,
                label: "Bandwidth Usage",
                color: Colors.purpleAccent,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Placeholder for detailed chart
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "Detailed Chart Goes Here",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





















/// ---------------- SUBSCRIPTION ANALYSIS ----------------
class SubscriptionAnalysisSection extends StatelessWidget {
  const SubscriptionAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnalysisContainer(
      title: "Subscription Analytics",
      stats: const [
        _AnalyticsCircle(percent: 0.72, label: "Active Subscriptions", color: Colors.greenAccent),
        _AnalyticsCircle(percent: 0.55, label: "New Subscriptions", color: Colors.blueAccent),
        _AnalyticsCircle(percent: 0.38, label: "Cancelled Subs", color: Colors.orangeAccent),
        _AnalyticsCircle(percent: 0.90, label: "Revenue Growth", color: Colors.purpleAccent),
      ],
    );
  }
}

/// ---------------- GIFTINGS ANALYSIS ----------------
class GiftingsAnalysisSection extends StatelessWidget {
  const GiftingsAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnalysisContainer(
      title: "Giftings Analytics",
      stats: const [
        _AnalyticsCircle(percent: 0.65, label: "Total Gifts", color: Colors.greenAccent),
        _AnalyticsCircle(percent: 0.48, label: "Active Gifters", color: Colors.blueAccent),
        _AnalyticsCircle(percent: 0.55, label: "Top Gifts Sent", color: Colors.orangeAccent),
        _AnalyticsCircle(percent: 0.78, label: "Revenue from Gifts", color: Colors.purpleAccent),
      ],
    );
  }
}

/// ---------------- GENERIC ANALYSIS CONTAINER ----------------
class _AnalysisContainer extends StatelessWidget {
  final String title;
  final List<Widget> stats;

  const _AnalysisContainer({required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Duration selector
          Row(
            children: [
              const Text(
                "Duration: ",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              DropdownButton<String>(
                dropdownColor: const Color(0xFF1E1F2E),
                value: "Day",
                items: <String>["Day", "Week", "Month", "Year"]
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  // Handle duration selection
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats,
          ),

          const SizedBox(height: 24),

          // Chart placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "Detailed Chart Goes Here",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ANALYTICS CIRCLE ----------------
class _AnalyticsCircle extends StatelessWidget {
  final double percent;
  final String label;
  final Color color;

  const _AnalyticsCircle({
    required this.percent,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 70,
      lineWidth: 10,
      percent: percent,
      animation: true,
      animationDuration: 900,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${(percent * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade800,
      progressColor: color,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}





class ReportsAndTicketsAnalysis extends StatelessWidget {
  const ReportsAndTicketsAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reports & Tickets Analytics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Duration Selector
          Row(
            children: [
              const Text(
                "Duration: ",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              DropdownButton<String>(
                dropdownColor: const Color(0xFF1E1F2E),
                value: "Week",
                items: const ["Day", "Week", "Month", "Year"]
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  // TODO: Handle duration change
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Analytics Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _AnalyticsCircle(
                percent: 0.68,
                label: "Abuse Reports",
                color: Colors.redAccent,
              ),
              _AnalyticsCircle(
                percent: 0.52,
                label: "Resolved Cases",
                color: Colors.greenAccent,
              ),
              _AnalyticsCircle(
                percent: 0.41,
                label: "Open Tickets",
                color: Colors.orangeAccent,
              ),
              _AnalyticsCircle(
                percent: 0.83,
                label: "Response Rate",
                color: Colors.blueAccent,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Placeholder for detailed graph
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "Reports & Tickets Trend Chart",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}