import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

import 'package:flutter/material.dart';
import 'package:punch/admin/screens/users.dart';
import 'package:punch/providers/dashboardPageProvider.dart';
import 'package:punch/screens/anniversaryList.dart';

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
        padding: const EdgeInsets.only(
          top: 6,
          bottom: 12,
          left: 12,
          right: 12
        ),
        child: Column(
          children: [
            const Expanded(
              child: Column(
                children: [
                  Header(),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: SizedBox(
                child: Consumer<DashboardPageProvider>(
                    builder: (context, pageProvider, _) {
                  return PageView(
                    controller: pageProvider.pageController,
                    onPageChanged: (index) {
                      pageProvider.setPageIndex(index);
                    },
                    children: const [
                      // const DashHome(),

                      AnniversaryList(),

                      UsersScreen(),
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
