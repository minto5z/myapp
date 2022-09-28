import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import '../elements/AppBarItem.dart';
import '../elements/WebViewElement.dart';
import '../elements/WebViewElementState.dart';
import '../enum/connectivity_status.dart';
import '../helpers/HexColor.dart';
import '../models/setting.dart';
import '../models/settings.dart';
import '../services/theme_manager.dart';

class WebScreen extends StatefulWidget {
  final String url;

  const WebScreen(this.url, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _WebScreen();
  }
}

class _WebScreen extends State<WebScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  GlobalKey<WebViewElementState> keyWebView = GlobalKey();
  String? title = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    var bottomPadding = mediaQueryData.padding.bottom;
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    var themeProvider = Provider.of<ThemeNotifier>(context);

    return Container(
        decoration: BoxDecoration(color: HexColor("#f5f4f4")),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBarItem(title: title!),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(children: [
                  Expanded(
                      child: WebViewElement(
                          key: keyWebView,
                          initialUrl: widget.url,
                          loader: GlobalConfiguration().getValue("loader"),
                          loaderColor: GlobalConfiguration().getValue("loaderColor"),
                          pullRefresh: GlobalConfiguration().getValue("pull_refresh"),
                          //userAgent: widget.settings.userAgent,
                          // customCss: Setting.getValue(
                          //     widget.settings.setting!, "customCss"),
                          // customJavascript: Setting.getValue(
                          //     widget.settings.setting!, "customJavascript"),
                          // // nativeApplication: widget.settings.nativeApplication,
                          // settings: widget.settings,
                          onLoadEnd: () => {
                                keyWebView.currentState!.webViewController!
                                    .getTitle()
                                    .then((String? result) {
                                  setState(() {
                                    title = result;
                                  });
                                })
                              }))
                ]),
              ],
            )));
  }
}
