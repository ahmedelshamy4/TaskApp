import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: mainColor,
  scaffoldBackgroundColor: white,
  backgroundColor: white,
  appBarTheme: const AppBarTheme(
    color: mainColor,
    titleSpacing: 20.0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: black,
      statusBarBrightness: Brightness.dark,
    ),
  ),
);
