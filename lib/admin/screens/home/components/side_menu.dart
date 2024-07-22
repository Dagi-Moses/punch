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
   sideMenu.SideMenuController sidemenu = sideMenu.SideMenuController();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardPageProvider>(context);
   

    return sideMenu.SideMenu(
      controller: sidemenu,
      style: sideMenu.SideMenuStyle(
        displayMode: sideMenu.SideMenuDisplayMode.auto,
        decoration: const BoxDecoration(),
        openSideMenuWidth: 200,
        compactSideMenuWidth: 40,
        hoverColor: Colors.red[200],
        selectedColor: punchRed,
        selectedIconColor: Colors.white,
        unselectedIconColor: Colors.white,
        backgroundColor: secondaryColor,
        selectedTitleTextStyle: const TextStyle(color: Colors.white),
        unselectedTitleTextStyle: const TextStyle(color: Colors.white),
        iconSize: 20,
        itemBorderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        showTooltip: true,
        showHamburger: Responsive.isDesktop(context) ? false : true,
        itemHeight: 50.0,
        selectedHoverColor: Colors.red[400],
        itemInnerSpacing: 8.0,
        itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0),
        toggleColor: Colors.black54,

        // Additional properties for expandable items
        selectedTitleTextStyleExpandable:
            const TextStyle(color: Colors.white), // Adjust the style as needed
        unselectedTitleTextStyleExpandable: const TextStyle(
            color: Colors.black54), // Adjust the style as needed
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
          const SizedBox(height: defaultPadding),
          Center(
            child: Image.network(
              "assets/images/punch_logo.png",
              scale: 5,
            ),
          ),
          const SizedBox(height: defaultPadding),
          const Text(
            'MOSES ',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
      items: [
        sideMenu.SideMenuItem(
          title: "Anniversary List",
          icon: const Icon(
            Icons.article,
          ),
          onTap: (index, _) {
            provider.setPageIndex(index);

            sidemenu.changePage(index);
          },
        ),
        sideMenu.SideMenuItem(
          title: "Users",
          icon: const Icon(
            Icons.people,
          ),
          onTap: (index, _) {
            provider.setPageIndex(index);
            sidemenu.changePage(index);
          },
        ),
      ],
    );
  }
}
