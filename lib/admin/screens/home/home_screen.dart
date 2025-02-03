import 'package:flutter/material.dart';

import 'package:punch/admin/screens/dashboard/dashboard_screen.dart';
import 'package:punch/admin/screens/home/components/header.dart';

import 'components/side_menu.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SideMenu(),
            Expanded(
              child: Column(
                children: [
                  Header(),
                  Expanded(child: DashboardScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
