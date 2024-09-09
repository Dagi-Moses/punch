import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

import 'package:flutter/material.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/screens/clientScreen.dart';
import 'package:punch/screens/main%20View.dart';
import 'package:punch/screens/users.dart';
import 'package:punch/providers/dashboardPageProvider.dart';

import 'package:punch/screens/companyScreen.dart';

import 'components/header.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.user?.loginId == UserRole.admin;
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
        child: Column(
          children: [
            Expanded(
          
              child: Consumer<DashboardPageProvider>(
                  builder: (context, pageProvider, _) {
                return PageView(
                  controller: pageProvider.pageController,
                  onPageChanged: (index) {
                    pageProvider.setPageIndex(index);
                  },
                  children: [
                    const MainView(),
                    const ClientScreen(),
                    const CompanyScreen(),
                    if (isAdmin) const UsersScreen(),
                  ],
                );
              }),
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
