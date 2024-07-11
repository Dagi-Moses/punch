import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';

import 'package:punch/admin/screens/dashboard/components/user_details_widget.dart';
import 'package:punch/widgets/anniversaryTable.dart';
import 'package:punch/widgets/anniversaryTable2.dart';

import '../admin/screens/dashboard/components/recent_forums.dart';
import '../widgets/main View.dart';

class AnniversaryList extends StatefulWidget {
  const AnniversaryList({super.key});

  @override
  State<AnniversaryList> createState() => _AnniversaryListState();
}

class _AnniversaryListState extends State<AnniversaryList> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [

            //AnniversaryTable2(),
            MainView(),
              // const SizedBox(height: defaultPadding),
              // const RecentDiscussions(),
              // if (Responsive.isMobile(context))
              //   const SizedBox(height: defaultPadding),
              // if (Responsive.isMobile(context)) const UserDetailsWidget(),
            ],
          ),
        ),
        // if (!Responsive.isMobile(context)) const SizedBox(width: defaultPadding),
        // // On Mobile means if the screen is less than 850 we dont want to show it
        // if (!Responsive.isMobile(context))
        //   const Expanded(
        //     flex: 2,
        //     child: UserDetailsWidget(),
        //   ),
      ],
    );
  }
}
