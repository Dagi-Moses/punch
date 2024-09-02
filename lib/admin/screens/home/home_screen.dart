import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/admin/screens/dashboard/dashboard_screen.dart';

import 'components/side_menu.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  backgroundColor: bgColor,

     
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
        ///    if (Responsive.isDesktop(context))
              
                // default flex = 1
                // and it takes 1/6 part of the screen
              
                // default flex = 1
                // and it takes 1/6 part of the screen
               SideMenu(),
              
            Expanded(
              // It takes 5/6 part of the screen
             
              child: DashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
