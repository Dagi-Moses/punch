import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/admin/screens/dashboard/components/mini_information_card.dart';
import 'package:punch/admin/screens/dashboard/components/recent_users.dart';
import 'package:punch/admin/screens/dashboard/components/user_details_widget.dart';

import '../admin/screens/dashboard/components/recent_forums.dart';

class DashHome extends StatefulWidget {
  const DashHome({super.key});

  @override
  State<DashHome> createState() => _DashHomeState();
}

class _DashHomeState extends State<DashHome> {
  @override
  Widget build(BuildContext context) {
    return  ListView(
     // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
             MiniInformation(),
            SizedBox(height: defaultPadding),
           
            RecentUsers(),
            SizedBox(height: defaultPadding),
            RecentDiscussions(),
            if (Responsive.isMobile(context))
              SizedBox(height: defaultPadding),
            if (Responsive.isMobile(context)) UserDetailsWidget(),
          ],
        ),
        if (!Responsive.isMobile(context)) SizedBox(width: defaultPadding),
        // On Mobile means if the screen is less than 850 we dont want to show it
        if (!Responsive.isMobile(context))
          Expanded(
            flex: 2,
            child: UserDetailsWidget(),
          ),
      ],
    );
  }
}