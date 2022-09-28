import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enum/connectivity_status.dart';
import '../helpers/HexColor.dart';
import '../models/settings.dart';
import '../services/theme_manager.dart';
import '../themes/UIImages.dart';

class OfflineScreen extends StatefulWidget {

  const OfflineScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OfflineScreen();
  }
}

class _OfflineScreen extends State<OfflineScreen> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    var bottomPadding = mediaQueryData.padding.bottom;
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    var themeProvider = Provider.of<ThemeNotifier>(context);

    return Container(
      decoration: BoxDecoration(color: HexColor("#f5f4f4")),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            Container(
              height: 80,
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: Image.asset(
                        UIImages.imageDir + "/wifi.png",
                        color: Colors.black26,
                        fit: BoxFit.contain,
                      )),
                  const SizedBox(height: 40),
                  // Text(
                  //   I18n.current!.whoops,
                  //   style: TextStyle(
                  //       color: Colors.black45,
                  //       fontSize: 40.0,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  const SizedBox(height: 20),
                  // Text(
                  //   I18n.current!.noInternet,
                  //   style: TextStyle(color: Colors.black87, fontSize: 15.0),
                  // ),
                  const SizedBox(height: 5),
                  const SizedBox(height: 60),
                  // RaisedGradientButton(
                  //     child: Text(
                  //       I18n.current!.tryAgain,
                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 18.0,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //     width: 250,
                  //     gradient: LinearGradient(
                  //       colors: <Color>[
                  //         HexColor(Setting.getValue(
                  //             widget.settings.setting!, "secondColor")),
                  //         HexColor(Setting.getValue(
                  //             widget.settings.setting!, "firstColor"))
                  //       ],
                  //     ),
                  //     onPressed: () {}),
                ]),
          ],
        ),
      ),
    );
  }
}
