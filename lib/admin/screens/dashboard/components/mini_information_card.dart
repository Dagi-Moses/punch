import 'package:provider/provider.dart';
import 'package:punch/admin/core/widgets/tickets.dart';

import 'package:flutter/material.dart';
import 'package:punch/admin/responsive.dart';
import 'package:punch/constants/constants.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';

class MiniInformation extends StatelessWidget {
  const MiniInformation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String anniversaries = Provider.of<AnniversaryProvider>(context).anniversaries.length.toString();
    // String user = Provider.of<AuthProvider>(context).users;
     final authProvider = Provider.of<AuthProvider>(context);
    final users = authProvider.mergedUsersWithRecords;
    List<String> randomNumbers = [
      anniversaries, users.length.toString(), ];
    return Column(
      children: <Widget>[
      Responsive.isMobile(context)
            ? SizedBox()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List<Widget>.generate(2, (i) {
                  return tickets(Colors.white, context, icons[i],
                      randomNumbers[i], newTexts[i]);
                })),
      ],
    );
  }
}
