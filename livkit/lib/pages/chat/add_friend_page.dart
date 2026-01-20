import 'package:flutter/material.dart';
import '../../services/friend_service.dart';
import '../../constants/chat_constants.dart';
import 'chat_message_page.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final FriendService _friendService = FriendService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);

    final users = await _friendService.searchUsers(query);

    setState(() {
      _results = users;
      _loading = false;
    });
  }

  void _addFriend(dynamic userId) async {
    final success = await _friendService.sendFriendRequest(userId.toString());
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Friend request sent!" : "Failed"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Friend")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search by username or email",
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ],
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, index) {
                final user = _results[index];

                final conversationId =
                    user["conversation_id"] ?? ChatConstants.globalConversationId;

                return ListTile(
                  title: Text(user["username"]),
                  subtitle: Text(user["email"] ?? ""),
                  trailing: ElevatedButton(
                    onPressed: () => _addFriend(user["id"]),
                    child: const Text("Add"),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          conversationId: user["conversation_id"] ??
                              ChatConstants.globalConversationId,
                          title: user["username"],
                          avatarUrl: user["avatar"] ??
                              "https://i.pravatar.cc/150?u=${user["username"]}",
                        ),
                      ),
                    );
                  },

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
