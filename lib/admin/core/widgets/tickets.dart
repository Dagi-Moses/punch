

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

Widget tickets(Color color, BuildContext context, IconData icon,
    String ticketsNumber, String newCount) {
  return Card(
  
   elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      padding: const EdgeInsets.all(16),
      width:
           MediaQuery.of(context).size.width / 6,
      height: MediaQuery.of(context).size.height / 7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 22,
                  color: secondaryColor,
                ),
                SizedBox(height: 8),
                Text(
                  newCount,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontFamily: 'HelveticaNeue',
                  ),
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                ticketsNumber,
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
