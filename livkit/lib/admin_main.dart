import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'admins/widgets/menu_app_controller.dart';
import 'admins/pages/login_screen.dart';
import 'admins/widgets/constants.dart';


import 'admins/pages/admins_dashboard.dart';
import 'admins/pages/admins_notification.dart';
import 'admins/pages/coming_soon.dart';
import 'admins/pages/analysis_page.dart';
import 'admins/pages/livestreams_page.dart';
import 'admins/pages/subscription_page.dart';
import 'admins/pages/reports_and_tickets.dart';
import 'admins/pages/manage_admin.dart';

import 'admins/services/admin_auth_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AdminAuthService();
  await auth.loadUserFromToken();

  final token = await auth.getToken();

  runApp(AdminApp(
    initialRoute: token == null ? '/' : '/admins_dashboard',
  ));
}



class AdminApp extends StatelessWidget {
  final String initialRoute;
  const AdminApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
     
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Panel',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      routes: {
        '/': (context) => SignInScreen(),
        
        '/admins_dashboard': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: AdminsMainScreen(),
            ),
        
        '/comingsoon': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: ComingSoon(),
            ),
        '/admins_notification': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: Admins_Notification_Main(),
            ),


        '/analysis_page': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: AdminsAnalysisMainScreen(),
            ),

        '/admins_livestreams': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: AdminsLivestreamsMainScreen(),
            ),
        '/admins_subscription': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: AdminsSubscriptionMainScreen(),
            ),
        '/admins_reports': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: AdminsReportsMainScreen(),
            ),
        '/manage_admins': (context) => 
            ChangeNotifierProvider(
              create: (_) => MenuAppController(),
              child: AdminsManageAdminsMainScreen(),
            ),
      },
    );
  }
}
