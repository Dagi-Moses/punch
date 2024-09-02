import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

import 'package:punch/screens/main%20View.dart';



class AnniversaryList extends StatefulWidget {
  const AnniversaryList({super.key});

  @override
  State<AnniversaryList> createState() => _AnniversaryListState();
}

class _AnniversaryListState extends State<AnniversaryList> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            
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
