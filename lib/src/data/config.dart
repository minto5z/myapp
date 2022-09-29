import 'package:flutter/material.dart';

class Config {
  /* Images Dir */
  static const String imageDir = "assets/img";

  /* Default Logo Application*/
  static Image logo =
      Image.asset("$imageDir/logo.png", height: 150, width: 150);
  static Image splash = Image.asset("$imageDir/splash.png");
  static Image wifi = Image.asset("$imageDir/wifi.png");
  static Image no = Image.asset("$imageDir/no.png",
      height: 50, width: 50, color: Colors.white);
}
