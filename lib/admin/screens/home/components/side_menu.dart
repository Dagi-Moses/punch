import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/providers/dashboardPageProvider.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart' as sideMenu;

class SideMenu extends StatefulWidget {
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardPageProvider>(context);
    sideMenu.SideMenuController sidemenu = sideMenu.SideMenuController();

    // @override
    // void initState() {
    //   sidemenu.addListener((index) {
    //     provider.pageController.jumpToPage(index);
    //   });
    //     super.initState();
    // }

    return sideMenu.SideMenu(
      controller: sidemenu,
      style: sideMenu.SideMenuStyle(
        displayMode: sideMenu.SideMenuDisplayMode.auto,
        decoration: BoxDecoration(),
        openSideMenuWidth: 200,
        compactSideMenuWidth: 40,
        hoverColor: Colors.red[200],
        selectedColor: Colors.redAccent,
        selectedIconColor: Colors.white,
        unselectedIconColor: Colors.white,
        backgroundColor: bgColor,
        selectedTitleTextStyle: TextStyle(color: Colors.white),
        unselectedTitleTextStyle: TextStyle(color: Colors.white),
        iconSize: 20,
        itemBorderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        showTooltip: true,
        showHamburger: Responsive.isDesktop(context)? false : true,
        itemHeight: 50.0,
        selectedHoverColor: Colors.red[400],
        itemInnerSpacing: 8.0,
        itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0),
        toggleColor: Colors.black54,

        // Additional properties for expandable items
        selectedTitleTextStyleExpandable:
            TextStyle(color: Colors.white), // Adjust the style as needed
        unselectedTitleTextStyleExpandable:
            TextStyle(color: Colors.black54), // Adjust the style as needed
        selectedIconColorExpandable: Colors.white, // Adjust the color as needed
        unselectedIconColorExpandable:
            Colors.black54, // Adjust the color as needed
        arrowCollapse: Colors.blueGrey, // Adjust the color as needed
        arrowOpen: Colors.lightBlueAccent, // Adjust the color as needed
        iconSizeExpandable: 24.0, // Adjust the size as needed
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
              SizedBox(height: defaultPadding),
          Center(
            child: Image.network(
              "assets/images/punch_logo.png",
              scale: 5,
            ),
          ),
          SizedBox(height: defaultPadding),
          Text(
            'MOSES ',
            style: TextStyle(color: Colors.white),
          ),
              SizedBox(height: defaultPadding),
        ],
      ),
      items: [
        sideMenu.SideMenuItem(
          title: "Dashboard",
          icon: Icon(
            Icons.dashboard,

          ),
          onTap: (index, _) {
          //  provider.setPageIndex(index);
            provider.pageController.jumpTo(index as double);
          },
        ),
        sideMenu.SideMenuItem(
          title: "Anniversary List",
          icon: Icon(Icons.article, ),
          onTap: (index, _) {
         //   provider.setPageIndex(index);
          provider.pageController.jumpTo(index as double);
          },
        ),
        sideMenu.SideMenuItem(
          title: "Users",
          icon: Icon(Icons.people,),
          onTap: (index, _) {
            provider.setPageIndex(index);
          },
        ),
        sideMenu.SideMenuItem(
          title: "categories",
          icon: Icon(Icons.category, ),
          onTap: (index, _) {
            provider.setPageIndex(index);
          },
        ),
        sideMenu.SideMenuItem(
          title: "appearance",
          icon: Icon(Icons.pallet,),
          onTap: (index, _) {
            provider.setPageIndex(index);
          },
        ),
        sideMenu.SideMenuItem(
          title: "Users",
          icon: Icon(Icons.people, ),
          onTap: (index, _) {
            provider.setPageIndex(index);
          },
        ),
        sideMenu.SideMenuItem(
          title: "Tools",
          icon: Icon(Icons.build,),
          onTap: (index, _) {
            provider.setPageIndex(index);
          },
        ),
        sideMenu.SideMenuItem(
          title: "settings",
          icon: Icon(Icons.settings,),
          onTap: (index, _) {
            provider.setPageIndex(index);
          },
        ),
      ],
    );
  }
}
