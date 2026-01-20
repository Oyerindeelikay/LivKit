import 'package:flutter/material.dart';
import '../../services/friend_service.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    final pending = await _friendService.getPendingRequests();
    if (!mounted) return;
    setState(() {
      _requests = pending;
      _loading = false;
    });
  }

  void _respond(int requestId, bool accept) async {
    final success = await _friendService.respondToRequest(requestId, accept);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept ? "Request accepted" : "Request rejected")));
      _fetchRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to respond")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Friend Requests")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text("No pending requests"))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (_, index) {
                    final req = _requests[index];
                    return ListTile(
                      title: Text(req["sender_username"]),
                      subtitle: Text(req["sender_email"] ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _respond(req["id"], true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _respond(req["id"], false),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
