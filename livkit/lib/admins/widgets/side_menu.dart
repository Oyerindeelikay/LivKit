import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/admin_auth_service.dart';



class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final _auth = AdminAuthService();
  bool isMainAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    await _auth.loadUserFromToken();
    setState(() {
      isMainAdmin = _auth.isMainAdmin;
    });
  }
  
  Future<void> _handleLogout(BuildContext context) async {
    await _auth.logout(); // <-- use _auth, not auth
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (_) => false,
    );
  }












  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),

          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              Navigator.pushNamed(context, '/admins_dashboard');
            },
          ),

          DrawerListTile(
            title: "Analysis",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
              Navigator.pushNamed(context, '/analysis_page');
            },
          ),

          DrawerListTile(
            title: "Live Streams",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {
              Navigator.pushNamed(context, '/admins_livestreams');
            },
          ),

          if (isMainAdmin)
            DrawerListTile(
              title: "subscription",
              svgSrc: "assets/icons/menu_store.svg",
              press: () {
                Navigator.pushNamed(context, '/admins_subscription');
              },
            ),

          DrawerListTile(
            title: "Abuse Reports & Tickets",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {
              Navigator.pushNamed(context, '/admins_reports');
            },
          ),

          ExpansionTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text(
              "Settings",
              style: TextStyle(color: Colors.white),
            ),
            children: [

              if (isMainAdmin)
                ListTile(
                  title: const Text("Manage Admins"),
                  onTap: () {
                    Navigator.pushNamed(context, '/manage_admins');
                  },
                ),
                
              ListTile(
                title: const Text("Logout"),
                onTap: () => _handleLogout(context),
              ),



            ],
          ),
        ],
      ),
    );
  }
}



class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}








