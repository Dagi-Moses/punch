import 'dart:ui';

import 'package:flutter/material.dart';

Color getRoleColor(int? role) {
  if (role == 1) {
    return Colors.green;
  } else if (role == 2) {
    return Colors.red;
  } else if (role == 3) {
    return Colors.blueAccent;
  } else if (role == 4) {
    return Colors.amberAccent;
  } else if (role == 5) {
    return Colors.cyanAccent;
  } else if (role == 6) {
    return Colors.deepPurpleAccent;
  } else if (role == 7) {
    return Colors.indigoAccent;
  }
   else if (role == 8) {
    return Colors.deepOrange;
  }
   else if (role == 9) {
    return Colors.teal;
  }
  return Colors.black38;
}
