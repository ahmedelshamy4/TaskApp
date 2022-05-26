import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: mainColor,
  scaffoldBackgroundColor: white,
  backgroundColor: white,
  appBarTheme: const AppBarTheme(
    backgroundColor: mainColor,
    titleSpacing: 20.0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: black,
      statusBarBrightness: Brightness.dark,
    ),
  ),
);
