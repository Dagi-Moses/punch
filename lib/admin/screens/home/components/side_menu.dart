import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/admin/screens/dashboard/components/header.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/dashboardPageProvider.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart' as sideMenu;
import 'package:punch/widgets/dialogs/dialogs/logout.dart';

class SideMenu extends StatefulWidget {
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  sideMenu.SideMenuController sidemenu = sideMenu.SideMenuController();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardPageProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isAdmin = auth.user?.loginId == UserRole.admin;

    return sideMenu.SideMenu(
    
      footer: const ProfileCard(),
      controller: sidemenu,
      style: sideMenu.SideMenuStyle(
      
        decoration: const BoxDecoration(),
    
        openSideMenuWidth:Responsive.isDesktop(context) ? 190: 130,
        compactSideMenuWidth: 60,
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
    
        showHamburger: Responsive.isMobile(context) ? true : false,
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
        arrowCollapse: Colors.yellow, // Adjust the color as needed
        arrowOpen: Colors.yellow, // Adjust the color as needed
        iconSizeExpandable: 24.0, // Adjust the size as needed
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: defaultPadding),
          Center(
            child: kIsWeb
                ? Image.network(
                    "assets/images/punch_logo.png",
                    scale: 5,
                  )
                : Image.asset(
                    "assets/images/punch_logo.png",
                    scale: 5,
                  ),
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
          title: "Client",
          icon: const Icon(
            Icons.group,
          ),
          onTap: (index, _) {
            provider.setPageIndex(index);
    
            sidemenu.changePage(index);
          },
        ),
        sideMenu.SideMenuItem(
          title: "Company",
          icon: const Icon(
            Icons.business,
          ),
          onTap: (index, _) {
            provider.setPageIndex(index);
            sidemenu.changePage(index);
          },
        ),
        if (isAdmin)
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
        sideMenu.SideMenuItem(
          badgeColor: Colors.red,
          title: "Logout",
          icon: const Icon(
            Icons.logout,
            color: Colors.red,
          ),
          onTap: (index, _) {
            logOut(context, () {
              Navigator.of(context).pop();
              auth.logout();
            });
          },
        ),
      ],
    );
  }
}
