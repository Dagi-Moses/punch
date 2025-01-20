import 'package:flutter/material.dart';

import 'package:punch/admin/screens/dashboard/dashboard_screen.dart';

import 'components/side_menu.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   

      // drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SideMenu(),
            Expanded(
              child: DashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
