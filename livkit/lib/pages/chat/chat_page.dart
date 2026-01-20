import 'package:flutter/material.dart';
import 'chat_message_page.dart';
import 'add_friend_page.dart';
import 'friend_request_page.dart';
import '../../services/friend_service.dart';
import '../../services/auth_service.dart';
class ChatPageList extends StatefulWidget {
  final String token;

  const ChatPageList({
    super.key,
    required this.token,
  });

  @override
  State<ChatPageList> createState() => _ChatPageListState();
}

class _ChatPageListState extends State<ChatPageList>
    with SingleTickerProviderStateMixin {
  // ---------------- FIELDS ----------------
  late final AnimationController _pageAnim;
  late final Animation<double> _fadeSlide;
  String? _myUsername;
  int? _myUserId;


  late final String userToken;

  bool hasPendingRequests = true;

  /// ✅ Conversations
  List<Map<String, dynamic>> _conversations = [];
  bool _loadingConversations = true;

  final FriendService _friendService = FriendService();



  @override
  void initState() {
    super.initState();

    userToken = widget.token;

    _pageAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeSlide =
        CurvedAnimation(parent: _pageAnim, curve: Curves.easeOutCubic);
    _pageAnim.forward();

    _init(); // <- call to async initializer
  }

  // Add this below initState()
  Future<void> _init() async {
    _myUsername = await AuthService().getUsername(); // must complete first
    _myUserId = await AuthService().getUserId();


    if (!mounted) return;

    await fetchConversations(); // only now fetch conversations
  }












  Future<void> fetchConversations() async {
    try {
      final List<Map<String, dynamic>> conversations =
          List<Map<String, dynamic>>.from(
            await _friendService.getConversations(),
          );

      final Map<String, Map<String, dynamic>> unique = {};

      for (final c in conversations) {
        final rawMembers = c["members"];

        if (rawMembers is! List || rawMembers.length != 2) continue;

        final List<String> members = rawMembers.map<String>((m) {
          if (m is String) return m;
          if (m is Map && m["username"] is String) return m["username"];
          return "";
        }).where((u) => u.isNotEmpty).toList();

        if (members.length != 2) continue;

        members.sort();
        final key = members.join("_");

        unique[key] = c;
      }

      final List<Map<String, dynamic>> deduped = unique.values.toList();

      deduped.sort((a, b) {
        final aDate = a["last_message_at"];
        final bDate = b["last_message_at"];

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return DateTime.parse(bDate)
            .compareTo(DateTime.parse(aDate));
      });

      if (!mounted) return;

      setState(() {
        _conversations = deduped;
        _loadingConversations = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingConversations = false;
      });

      debugPrint("Error fetching conversations: $e");
    }
  }



  @override
  void dispose() {
    _pageAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeSlide,
        child: Transform.translate(
          offset: const Offset(0, 12),
          child: Column(
            children: [
              _buildStatusSection(),
              const Divider(color: Colors.white12),
              if (hasPendingRequests)
                _AnimatedFanClub(
                  priority: true,
                  child: _buildPendingRequestsCard(),
                ),
              Expanded(
                child: _loadingConversations
                    ? const Center(child: CircularProgressIndicator())
                    : _conversations.isEmpty
                        ? const Center(
                            child: Text(
                              "No conversations yet",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _conversations.length,
                            itemBuilder: (_, index) {
                              final c = _conversations[index];
                              return _AnimatedChatItem(
                                delay: index * 80,
                                child: _chatItem(conversation: c),
                              );
                            },

                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getConversationDisplayName(Map<String, dynamic> conversation) {
    final rawMembers = conversation["members"];
    if (rawMembers is! List) return "Chat";

    final myId = _myUserId; // store this during _init()
    if (myId == null) return "Chat";

    for (final m in rawMembers) {
      if (m is Map && m["id"] != myId) {
        return m["username"] ?? "Chat";
      }
    }

    return "Chat";
  }









  // ---------------- CHAT ITEM ----------------
  // ---------------- CHAT ITEM ----------------
  Widget _chatItem({
    required Map<String, dynamic> conversation,
  }) {
    final displayName = _getConversationDisplayName(conversation);
    final lastMsg = conversation["last_message"];
    final message = lastMsg?["content"]?["text"] ?? "";
    final time = lastMsg?["created_at"] ?? "";
    final avatar = "https://i.pravatar.cc/150?u=${conversation["id"]}";
    final conversationId = conversation["id"];

    return ListTile(
      leading: _buildAvatar(displayName),

      title: Text(
        displayName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white, // ✅ force white
        ),
      ),


      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70),
      ),

      trailing: Text(
        time.isNotEmpty ? time.split("T").first : "",
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),

      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        try {
          String convId = conversationId;
          String convTitle = displayName;
          String convAvatar = avatar;

          if (convId.startsWith("friend_")) {
            final friendId =
                int.tryParse(convId.replaceFirst("friend_", ""));
            if (friendId == null) throw Exception("Invalid friend ID");

            final conv =
                await _friendService.getOrCreateFriendConversation(friendId);

            convId = conv["id"];
            convTitle = displayName;
          }

          if (!mounted) return;
          Navigator.pop(context);

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                conversationId: convId,
                title: convTitle,
                avatarUrl: convAvatar,
              ),
            ),
          );

          if (!mounted) return;

          // Refresh conversations when coming back
          fetchConversations();

        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to open chat: $e")),
          );
        }
      },
    );
  }





  // ---------------- STATUS ----------------
  Widget _buildStatusSection() {
    return SizedBox(
      height: 95,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _AnimatedStatusItem(
            child: _statusItem("Add Friends", "", true),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String name, String avatar, bool isAdd) {
    return GestureDetector(
      onTap: () {
        if (isAdd) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFriendPage()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isAdd ? Colors.blue : Colors.white24,
              child: isAdd
                  ? const Icon(Icons.person_add, color: Colors.white)
                  : CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(avatar),
                    ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String username) {
    final color = Colors.primaries[username.hashCode % Colors.primaries.length];
    return CircleAvatar(
      radius: 24,
      backgroundColor: color,
      child: Text(
        username.substring(0, 1).toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }


  // ---------------- PENDING REQUESTS CARD ----------------
  Widget _buildPendingRequestsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PendingRequestsPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: const [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pending Friend Requests",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Tap to view and respond to requests",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}

// ================= ANIMATED HELPERS =================
class _AnimatedChatItem extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedChatItem({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 20, end: 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / 20),
            child: child,
          ),
        );
      },
    );
  }
}

class _AnimatedStatusItem extends StatelessWidget {
  final Widget child;

  const _AnimatedStatusItem({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
    );
  }
}

class _AnimatedFanClub extends StatelessWidget {
  final Widget child;
  final bool priority;

  const _AnimatedFanClub({required this.child, required this.priority});

  @override
  Widget build(BuildContext context) {
    return priority
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.97, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, _) {
              return Transform.scale(scale: value, child: child);
            },
          )
        : child;
}
}
