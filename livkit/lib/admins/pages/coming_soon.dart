import '../widgets/menu_app_controller.dart';
import '../widgets/responsive.dart';
import 'admins_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/side_menu.dart';

class ComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,

              child: Admins_Transaction(),
            ),
          ],
        ),
      ),
    );
  }
}

class Admins_Transaction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2A), // Matches the background color in your image
      body: Row(
        children: [
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header with Title, Back Button, and Add New Appointment Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: const Color(0xFF1E1E2A),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (!Responsive.isDesktop(context))
                            IconButton(
                              icon: Icon(Icons.menu),
                              onPressed: context.read<MenuAppController>().controlMenu,
                            ),
                          const SizedBox(width: 10),
                          Text(
                            "Transactions",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main "Coming Soon!!!" text in the center
                Expanded(
                  child: Center(
                    child: Text(
                      "Coming Soon!!!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48, // Very big font size
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



