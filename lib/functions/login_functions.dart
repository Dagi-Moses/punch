import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:punch/animated_login.dart';
import 'package:flutter/material.dart';
import 'package:punch/constants/constants.dart';
import 'package:punch/models/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/utils/dialog_builders.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class LoginFunctions {
  /// Collection of functions will be performed on login/signup.
  /// * e.g. [onLogin], [onSignup], [socialLogin], and [onForgotPassword]
  const LoginFunctions(this.context);
  final BuildContext context;

  
    
  /// Action that will be performed on click to "Forgot Password?" text/CTA.
  /// Probably you will navigate user to a page to create a new password after the verification.
  Future<String?> onForgotPassword(String email) async {
    DialogBuilder(context).showLoadingDialog();
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed('/forgotPass');
    return null;
  }
}
