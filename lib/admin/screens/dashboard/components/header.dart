import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:punch/providers/authProvider.dart';


class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    // Determine sizes based on the device's screen size
    double cardHeight = Responsive.isMobile(context) ? 50 : 60;
    double horizontalPadding =
        Responsive.isMobile(context) ? defaultPadding / 2 : defaultPadding/1.4;
    double verticalPadding =
        Responsive.isMobile(context) ? defaultPadding / 4 : defaultPadding / 2;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: cardHeight,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
              if (Responsive.isDesktop(context)) CircleAvatar(
              backgroundImage: AssetImage("assets/images/profile_pic.png"),
            ),
            if (!Responsive.isTablet(context))
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the left
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center text vertically
                  children: [
                    Text(
                      user!.loginId.toString().split('.').last,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium, // Adjust the text style
                    ),
                    Text(
                      user.lastName!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium, // Adjust the text style
                    ),
                  ],
                ),
              ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search",
          fillColor: Colors.white,
          filled: true,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          suffixIcon: InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(defaultPadding * 0.75),
              margin:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              decoration: const BoxDecoration(
                color: punchRed,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: SvgPicture.asset(
                "assets/icons/Search.svg",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
