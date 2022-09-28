import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';

import '../helpers/HexColor.dart';
import '../models/setting.dart';
import '../models/settings.dart';
import '../services/theme_manager.dart';

class AppBarItem extends StatefulWidget implements PreferredSizeWidget {
  String title;

  AppBarItem({Key? key, this.title = ""})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AppBarItem();
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _AppBarItem extends State<AppBarItem> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                themeProvider.isLightTheme
                    ? HexColor(GlobalConfiguration().getValue("firstColor"))
                    : themeProvider.darkTheme.primaryColor,
                themeProvider.isLightTheme
                    ? HexColor(GlobalConfiguration().getValue("secondColor"))
                    : themeProvider.darkTheme.primaryColor,
              ],
            ),
          ),
        ));
  }
}
