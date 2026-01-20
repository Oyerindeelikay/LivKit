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



class AdminsSubscriptionMainScreen extends StatelessWidget {
 const AdminsSubscriptionMainScreen({super.key});

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
              child: AdminsSubscriptionPage(),
            ),
          ],
        ),
      ),
    );
  }
}


class AdminsSubscriptionPage extends StatelessWidget {
 const AdminsSubscriptionPage({super.key});

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
                      SubscriptionAnalysisSection(),
                      SubscriptionOptionsList(),

                      SizedBox(height: defaultPadding),




                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) SubscriptionDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: SubscriptionDetails(),
                    
                    
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
              "Active Subscription Overview",
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
                Navigator.pushNamed(context, '/admins_subscription');
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



class AdminOptionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  AdminOptionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}


class SubscriptionOptionsList extends StatelessWidget {
  const SubscriptionOptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: options.map((item) {
          return _OptionTile(item: item);
        }).toList(),
      ),
    );
  }

  List<AdminOptionItem> _buildOptions(BuildContext context) {
    return [
      AdminOptionItem(
        icon: Icons.subscriptions,
        title: 'Subscription Plans',
        subtitle: 'Manage pricing, tiers & benefits',
        onTap: () => _openDialog(context, 'Subscription Plans'),
      ),
      AdminOptionItem(
        icon: Icons.workspace_premium,
        title: 'Premium Features',
        subtitle: 'Control premium access & perks',
        onTap: () => _openDialog(context, 'Premium Features'),
      ),
      AdminOptionItem(
        icon: Icons.payment,
        title: 'Premium Payments',
        subtitle: 'Gateways, failures & confirmations',
        onTap: () => _openDialog(context, 'Premium Payments'),
      ),
      AdminOptionItem(
        icon: Icons.card_giftcard,
        title: 'Gifts Management',
        subtitle: 'Create, price & control virtual gifts',
        onTap: () => _openDialog(context, 'Gifts Management'),
      ),
      AdminOptionItem(
        icon: Icons.account_balance_wallet,
        title: 'Coins & Wallet',
        subtitle: 'Coin packs, bonuses & limits',
        onTap: () => _openDialog(context, 'Coins & Wallet'),
      ),
      AdminOptionItem(
        icon: Icons.people_alt,
        title: 'Subscribers',
        subtitle: 'Active, expired & banned users',
        onTap: () => _openDialog(context, 'Subscriber Management'),
      ),
      AdminOptionItem(
        icon: Icons.percent,
        title: 'Revenue Split',
        subtitle: 'Admin & streamer earnings',
        onTap: () => _openDialog(context, 'Revenue Split'),
      ),
      AdminOptionItem(
        icon: Icons.campaign,
        title: 'Promotions & Discounts',
        subtitle: 'Promo codes, trials & offers',
        onTap: () => _openDialog(context, 'Promotions'),
      ),
      AdminOptionItem(
        icon: Icons.autorenew,
        title: 'Auto-Renewal',
        subtitle: 'Subscription renewal control',
        onTap: () => _openDialog(context, 'Auto-Renewal'),
      ),
      AdminOptionItem(
        icon: Icons.receipt_long,
        title: 'Logs & Reports',
        subtitle: 'Payments, gifts & subscriptions',
        onTap: () => _openDialog(context, 'System Logs'),
      ),
    ];
  }

  void _openDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2D),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'This popup will manage this functionality.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}



class _OptionTile extends StatelessWidget {
  final AdminOptionItem item;

  const _OptionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.deepPurpleAccent),
      title: Text(
        item.title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
      onTap: item.onTap,
    );
  }
}


