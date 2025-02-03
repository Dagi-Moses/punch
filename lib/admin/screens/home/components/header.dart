
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/models/myModels/headerItem.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/screens/ManageTypes/manageTitlePage.dart';





class Header extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {

  @override
  Widget build(BuildContext context) {
     final auth = Provider.of<AuthProvider>(context);
  
    final isUser = auth.user?.loginId == UserRole.user;

List<HeaderItem>? headerItems = [
    if(!isUser)
      HeaderItem(
          title: "TITLES",
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ManageTitlePage();
            }));
          }),
   //   HeaderItem(title: "SERVICES", onTap: () {}),
    ];

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),


 
      child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
        children: headerItems!
            .map(
              (item) => item.isButton
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        decoration: BoxDecoration(
                        
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, 
                            //vertical: 5.0
                            ),
                        child: TextButton(
                          onPressed: item.onTap,
                          // style: TextButton.styleFrom(
                          //    padding: EdgeInsets.zero, // Removes the padding
                          //   minimumSize: Size(0,
                          //       0), // Optional: Adjust the minimum size if needed
                          //   tapTargetSize: MaterialTapTargetSize
                          //       .shrinkWrap, // Reduces the tap target size
                          // ),
                          child: Text(
                            item.title,
                            style: const TextStyle(
                                color: punchRed,
                            //  color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        margin: const EdgeInsets.only(right: 30.0),

                        child: GestureDetector(
                          onTap: item.onTap,
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: punchRed,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
            )
            .toList(),
      ),
    );
  }
}

  // mobile header

