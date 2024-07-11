// import 'package:flutter/material.dart';
// import 'package:punch/admin/models/recent_user_model.dart';
// import 'package:xtable/xtable.dart';


// class CustomTable extends StatelessWidget {
//   final List<RecentUser> recentUsers;

//   CustomTable({required this.recentUsers});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         color: Colors.black,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: XTable(
//             columnWidths: [100, 100, 150, 100, 50, 100],
//             data: [
//               ['Title', 'Placed By', 'E-mail', 'Date', 'Id', 'Operation'],
//               ...recentUsers.map((user) => [
//                     user.title,
//                     user.placedBy,
//                     user.email,
//                     user.date,
//                     user.id,
//                     user.operation,
//                   ]),
//             ],
//             cellStyle: XTableCellStyle(
//               padding: EdgeInsets.all(8.0),
//               textStyle: TextStyle(color: Colors.white),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.white),
//               ),
//             ),
//             headerStyle: XTableCellStyle(
//               padding: EdgeInsets.all(8.0),
//               textStyle:
//                   TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.white),
//                 color: Colors.grey[800],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

