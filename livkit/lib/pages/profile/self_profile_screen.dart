import 'package:flutter/material.dart';
import '../settings/settings.dart';
import '../../services/auth_service.dart';


class SelfProfileScreen extends StatefulWidget {
  const SelfProfileScreen({super.key});

  @override
  State<SelfProfileScreen> createState() => _SelfProfileScreenState();
}

class _SelfProfileScreenState extends State<SelfProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final AuthService _authService = AuthService();

  bool _loading = true;

  String? _avatarUrl;
  String _displayName = "";
  String _username = "";
  String _bio = "";

  // mock for now (later backend)
  int postsCount = 0;
  int followersCount = 0;
  int followingCount = 0;


  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
    _loadProfile();
  }


  Future<void> _loadProfile() async {
    try {
      final data = await _authService.fetchUserData();
      final profile = data["profile"] ?? {};

      setState(() {
        _username = data["username"] ?? "";
        _displayName = profile["display_name"] ?? "";
        _bio = profile["bio"] ?? "";
        _avatarUrl = profile["avatar"];

        // mock values for now
        postsCount = 3;
        followersCount = 88;
        followingCount = 127;

        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load profile")),
      );
    }
  }



  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(



          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // 🔝 TOP BAR + PROFILE HEADER (SCROLLS AWAY)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              const Spacer(),
                              Text(
                                _username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Settings()),
                                  );
                                },
                              ),

                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white12,
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? const Icon(Icons.person, color: Colors.white, size: 40)
                              : null,
                        ),


                        const SizedBox(height: 10),

                        Text(
                          _displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "@$_username",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),


                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _statItem(postsCount.toString(), "Posts"),
                            _divider(),
                            _statItem(followersCount.toString(), "Followers"),
                            _divider(),
                            _statItem(followingCount.toString(), "Following"),
                          ],
                        ),


                        const SizedBox(height: 16),
                      ],

                      
                    ),
                  ),


                  SliverToBoxAdapter(
                    child: _bio.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Text(
                                  _bio,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  


                  // 📑 STICKY TAB BAR
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        indicatorWeight: 2,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white38,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on)),
                          Tab(icon: Icon(Icons.video_collection_outlined)),
                          Tab(icon: Icon(Icons.person_pin_outlined)),
                        ],
                      ),
                    ),
                  ),
                ];
              },

              // 🧩 TAB CONTENT
              body: TabBarView(
                controller: _tabController,
                children: [
                  // 🟦 POSTS GRID
                  GridView.builder(
                    padding: const EdgeInsets.all(4),
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.image,
                            color: Colors.white54),
                      );
                    },
                  ),

                  // 🎥 VIDEOS / LIVES
                  ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.live_tv,
                                color: Colors.redAccent),
                            SizedBox(width: 12),
                            Text(
                              "Live stream replay",
                              style:
                                  TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 🏷️ TAGGED
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_pin_outlined,
                            size: 60, color: Colors.white24),
                        SizedBox(height: 10),
                        Text(
                          "No tagged posts yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 STAT ITEM
  static Widget _statItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  static Widget _divider() {
    return Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white12,
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
