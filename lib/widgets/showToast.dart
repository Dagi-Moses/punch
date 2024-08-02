import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToaster(String msg, Toast toastLength, Color backgroundColor) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: backgroundColor,
    textColor: Colors.white,
  );
}
