import '../widgets/menu_app_controller.dart';
import '../widgets/responsive.dart';
import 'admins_dashboard.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../widgets/components/header.dart';
import '../widgets/components/system_insights.dart';

import '../widgets/side_menu.dart';
import '../widgets/constants.dart';
import '../widgets/components/tables.dart';
import '../widgets/components/charts.dart';



class AdminsLivestreamsMainScreen extends StatelessWidget {
 const AdminsLivestreamsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuAppController = Provider.of<MenuAppController>(context);

    return Scaffold(
      key: menuAppController.scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
             Expanded(child: SideMenu()),

            const Expanded(
              flex: 5,
              child: AdminsAnalysisPage(),
            ),
          ],
        ),
      ),
    );
  }
}


class AdminsAnalysisPage extends StatelessWidget {
 const AdminsAnalysisPage({super.key});

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


                      Refresh(),
                      const LiveStreamAnalysis(),
                      
                      LiveStreamControlQueue(),
                      SizedBox(height: defaultPadding),




                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) LivestreamsDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: LivestreamsDetails(),
                    
                    
                  ),



                  
              ],
            )
          ],
        ),
      ),
    );
  }
}


class Refresh extends StatelessWidget {
  const Refresh({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Livestreams Overview",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/admins_livestreams');
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
