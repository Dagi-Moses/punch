import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: bgColor,
      child: SingleChildScrollView(
        // it enables scrolling
        child: Column(
          children: [
            DrawerHeader(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: defaultPadding * 3,
                ),
                Center(
                  child: Image.asset(
                    "assets/images/punch_logo.png",
                    scale: 5,
                  ),
                ),
                SizedBox(
                  height: defaultPadding,
                ),
              
                Row(

                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.amber,
                    ),
                    SizedBox( width: 14,),
                    Text('MOSES -H', style: TextStyle(color: Colors.white),),
                  ],
                ),
              ],
            )),
            DrawerListTile(
              title: "Dashboard",
              svgSrc: Icons.dashboard,
              press: () {},
            ),
            DrawerListTile(
              title: "Posts",
              svgSrc: Icons.article,
              press: () {},
            ),
            DrawerListTile(
              title: "Pages",
              svgSrc: Icons.pages,
              press: () {},
            ),
            DrawerListTile(
              title: "Categories",
              svgSrc: Icons.category,
              press: () {},
            ),
            DrawerListTile(
              title: "Appearance",
              svgSrc: Icons.palette,
              press: () {},
            ),
            DrawerListTile(
              title: "Users",
              svgSrc: Icons.people,
              press: () {},
            ),
            DrawerListTile(
              title: "Tools",
              svgSrc: Icons.build,
              press: () {},
            ),
            DrawerListTile(
              title: "Settings",
              svgSrc: Icons.settings,
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(svgSrc,
      color: Colors.amber,
      size: 17,
      ),
      // leading: SvgPicture.asset(
      //   svgSrc,
      //   color: Colors.white54,
      //   height: 16,
      // ),
      title: Text(
        title,
        style: TextStyle(
          
          color: Colors.white54),
      ),
    );
  }
}
