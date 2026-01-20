import '../widgets/responsive.dart';
import '../widgets/menu_app_controller.dart';
import '../widgets/components/platform_overview.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../widgets/constants.dart';
import '../widgets/components/header.dart';
import '../widgets/side_menu.dart';

import '../widgets/components/tables.dart';
import '../widgets/components/system_insights.dart';


class AdminsMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuAppController = Provider.of<MenuAppController>(context);

    return Scaffold(
      key: menuAppController.scaffoldKey, // Ensure unique GlobalKey is used
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show side menu for large screens only
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: Admins_Dashboard(),
            ),
          ],
        ),
      ),
    );
  }
}



class Admins_Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [


            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [


                      MyFiles(),
                      SizedBox(height: defaultPadding),


                      AdminsActivityTable(),

                      LiveStreamControlQueue(),


                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) StorageDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: StorageDetails(),
                    
                    
                  ),



                  
              ],
            )
          ],
        ),
      ),
    );
  }
}
