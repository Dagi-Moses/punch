import 'package:flutter/material.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

Widget alignedHeaderText({required String title}){
  return  Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                        title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: punchRed,
                          ),
                        ),
                      );
}