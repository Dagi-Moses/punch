import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';

import 'package:punch/admin/screens/dashboard/components/mini_information_card.dart';

import 'package:punch/admin/screens/dashboard/components/recent_forums.dart';
import 'package:punch/admin/screens/dashboard/components/recent_users.dart';
import 'package:punch/admin/screens/dashboard/components/user_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:punch/admin/screens/users.dart';
import 'package:punch/providers/dashboardPageProvider.dart';
import 'package:punch/screens/anniversaryList.dart';
import 'package:punch/screens/dashHome.dart';

import 'components/header.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Expanded(
              child: Column(
                children: [
                  Header(),
                  SizedBox(height: defaultPadding),
                 
                ],
              ),
            ),
           
            Expanded(
              flex: 5,
              child: SizedBox(
                child: Consumer<DashboardPageProvider>(
                    builder: (context, pageProvider, _) {
                  return PageView(
                  
                    controller:pageProvider.pageController,
                       
                    onPageChanged: (index) {
                      pageProvider.setPageIndex(index);
                    },
                    children: [
                       const AnniversaryList(),
                      const DashHome(),
                     
                      const UsersScreen(),
                     Container(
                          color: Colors.yellow), // Example screen for "Pages"
                      Container(
                          color: Colors.black), // Example screen for "Pages"
                      Container(color: Colors.green),
                      Container(
                          color: Colors.green), // Example screen for "Pages"
                      Container(
                          color: Colors.green), // Example screen for "Pages"
                      Container(
                          color: Colors.green), // Example screen for "Pages"
                      Container(
                          color: Colors.green), // Example screen for "Pages"
                      Container(
                          color: Colors.green), // Example screen for "Pages"
                    
                    ],
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
@override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = Provider.of<DashboardPageProvider>(context, listen: false);
    if (provider.selectedIndex != provider.pageController.page?.toInt()) {
      provider.pageController.jumpToPage(provider.selectedIndex);
    }
  }
}
