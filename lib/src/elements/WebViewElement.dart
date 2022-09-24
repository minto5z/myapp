import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/settings.dart';
import 'WebViewElementState.dart';
//import 'package:store_redirect/store_redirect.dart';

class WebViewElement extends StatefulWidget {
  String? initialUrl;
  String? loader;
  String? loaderColor;
  String? pullRefresh = "true";
  String? customCss;
  String? customJavascript;
  Settings settings;
  void Function()? onLoadEnd = () => {};

  WebViewElement(
      {Key? key,
      this.initialUrl,
      this.loader,
      this.loaderColor,
      this.pullRefresh,
      this.customCss,
      this.customJavascript,
      required this.settings,
      this.onLoadEnd})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => WebViewElementState();
}
