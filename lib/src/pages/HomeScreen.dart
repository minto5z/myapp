import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/src/elements/WebViewElement.dart';

import '../elements/WebViewElementState.dart';
import '../helpers/HexColor.dart';
import '../models/setting.dart';
import '../models/settings.dart';

GlobalKey<WebViewElementState> key0 = GlobalKey();
GlobalKey<WebViewElementState> key1 = GlobalKey();
GlobalKey<WebViewElementState> key2 = GlobalKey();
GlobalKey<WebViewElementState> key3 = GlobalKey();
GlobalKey<WebViewElementState> key4 = GlobalKey();
GlobalKey<WebViewElementState> keyMain = GlobalKey();
GlobalKey<WebViewElementState> keyWebView = GlobalKey();
List<GlobalKey<WebViewElementState>> listKey = [key0, key1, key2, key3, key4];

StreamController<int> _controllerStream0 = StreamController<int>();
StreamController<int> _controllerStream1 = StreamController<int>();
StreamController<int> _controllerStream2 = StreamController<int>();
StreamController<int> _controllerStream3 = StreamController<int>();
StreamController<int> _controllerStream4 = StreamController<int>();
List<StreamController<int>> listStream = [
  _controllerStream0,
  _controllerStream1,
  _controllerStream2,
  _controllerStream3,
  _controllerStream4
];

class HomeScreen extends StatefulWidget {
  final String url;
  final Settings settings;

  const HomeScreen(this.url, this.settings, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int _currentIndex = 0;
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  bool goToWeb = true;
  var appLanguage;
  String url = "";

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 1, vsync: this);
    tabController.addListener(_handleTabSelection);

    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {}

  _handleTabSelection() {
    setState(() {
      _currentIndex = tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    var bottomPadding = mediaQueryData.padding.bottom;

    return WillPopScope(
        onWillPop: () async {
          getCurrentKey().currentState!.goBack();
          return false;
        },
        child: Container(
            decoration: BoxDecoration(color: HexColor("#f5f4f4")),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Scaffold(
              key: _scaffoldKey,
              // appBar: AppBarHomeItem(
              //     settings: widget.settings,
              //     currentIndex: _currentIndex,
              //     listKey: listKey,
              //     scaffoldKey: _scaffoldKey),
              // drawer: (widget.settings.leftNavigationIcon!.value ==
              //             "icon_menu" ||
              //         widget.settings.rightNavigationIcon!.value == "icon_menu")
              //     ? SideMenuElement(settings: widget.settings, key0: key0)
              //     : null,
              body: Stack(fit: StackFit.expand, children: [
                Column(children: [
                  // if (Setting.getValue(
                  //         widget.settings.setting!, "tab_position") ==
                  //     "top")
                    // TabNavigationMenu(
                    //     settings: widget.settings,
                    //     listStream: listStream,
                    //     tabController: tabController,
                    //     currentIndex: _currentIndex),

                    //Text(Setting.getValue(widget.settings.setting!, "tab_position")),
                    Expanded(
                      child: WebViewElement(
                          key: listKey[0],
                          initialUrl: 'http://63.142.251.34:8100',
                          //renderLang("url", languageCode),
                          loader: Setting.getValue(
                              widget.settings.setting!, "loader"),
                          loaderColor: Setting.getValue(
                              widget.settings.setting!, "loaderColor"),
                          pullRefresh: Setting.getValue(
                              widget.settings.setting!, "pull_refresh"),
                          customCss: Setting.getValue(
                              widget.settings.setting!, "customCss"),
                          customJavascript: Setting.getValue(
                              widget.settings.setting!, "customJavascript"),
                          settings: widget.settings),
                      // child: Setting.getValue(widget.settings.setting!,
                      //             "tab_navigation_enable") ==
                      //         "true"
                      //     ? TabBarView(
                      //         controller: tabController,
                      //         physics: NeverScrollableScrollPhysics(),
                      //         children: List.generate(widget.settings.tab!.length,
                      //             (index) {
                      //           return WebViewElement(
                      //               key: listKey[index],
                      //               initialUrl: renderTabUrl(index, languageCode),
                      //               loader: Setting.getValue(
                      //                   widget.settings.setting!, "loader"),
                      //               loaderColor: Setting.getValue(
                      //                   widget.settings.setting!, "loaderColor"),
                      //               pullRefresh: Setting.getValue(
                      //                   widget.settings.setting!, "pull_refresh"),
                      //               userAgent: widget.settings.userAgent,
                      //               customCss: Setting.getValue(
                      //                   widget.settings.setting!, "customCss"),
                      //               customJavascript: Setting.getValue(
                      //                   widget.settings.setting!,
                      //                   "customJavascript"),
                      //               nativeApplication:
                      //                   widget.settings.nativeApplication,
                      //               settings: widget.settings);
                      //         }),
                      //       )
                      //     : TabBarView(
                      //         controller: tabController,
                      //         physics: NeverScrollableScrollPhysics(),
                      //         children: List.generate(1, (index) {
                      //           return WebViewElement(
                      //               key: listKey[0],
                      //               initialUrl: renderLang("url", languageCode),
                      //               loader: Setting.getValue(
                      //                   widget.settings.setting!, "loader"),
                      //               loaderColor: Setting.getValue(
                      //                   widget.settings.setting!, "loaderColor"),
                      //               pullRefresh: Setting.getValue(
                      //                   widget.settings.setting!, "pull_refresh"),
                      //               userAgent: widget.settings.userAgent,
                      //               customCss: Setting.getValue(
                      //                   widget.settings.setting!, "customCss"),
                      //               customJavascript: Setting.getValue(
                      //                   widget.settings.setting!,
                      //                   "customJavascript"),
                      //               nativeApplication:
                      //                   widget.settings.nativeApplication,
                      //               settings: widget.settings);
                      //         }),
                      //       ),
                    )
                ])
              ]),
              // bottomNavigationBar:
              //     Setting.getValue(widget.settings.setting!, "tab_position") ==
              //             "bottom"
              //         ? TabNavigationMenu(
              //             settings: widget.settings,
              //             listStream: listStream,
              //             tabController: tabController,
              //             currentIndex: _currentIndex)
              //         : null,
              // floatingActionButton:
              //     FloatingButton(settings: widget.settings, key0: key0),
            )));
  }

  GlobalKey<WebViewElementState> getCurrentKey() {
    switch (_currentIndex) {
      case 0:
        {
          return key0;
        }
      case 1:
        {
          return key1;
        }

      case 2:
        {
          return key2;
        }
      case 3:
        {
          return key3;
        }
      case 4:
        {
          return key4;
        }
      default:
        {
          return key0;
        }
    }
  }

  GlobalKey<WebViewElementState> getKeyByIndex(index) {
    switch (index) {
      case 0:
        {
          return key0;
        }

      case 1:
        {
          return key1;
        }

      case 2:
        {
          return key2;
        }
      case 3:
        {
          return key3;
        }
      case 4:
        {
          return key4;
        }
      default:
        {
          return key0;
        }
    }
  }

  String renderLang(type, languageCode) {
    if (widget.settings.translation[languageCode] != null) {
      if (widget.settings.translation[languageCode] != null) {
        return widget.settings.translation[languageCode]![type]!;
      }
    }
    return " ";
  }
}

/*
WebViewElement(
                initialUrl: Setting.getValue(widget.settings.setting!, "url"),
                loader: Setting.getValue(widget.settings.setting!, "loader"),
                loaderColor:
                    Setting.getValue(widget.settings.setting!, "loaderColor"),
                pullRefresh:
                    Setting.getValue(widget.settings.setting!, "pull_refresh"),
                userAgent: widget.settings.userAgent,
                customCss:
                    Setting.getValue(widget.settings.setting!, "customCss"),
                customJavascript: Setting.getValue(
                    widget.settings.setting!, "customJavascript"),
                nativeApplication: widget.settings.nativeApplication,
              ),
 */
