import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';

import '../helpers/SharedPref.dart';
import '../models/setting.dart';
import '../models/settings.dart';

ValueNotifier<Settings> setting = ValueNotifier(Settings());

class SettingsService {
  // void getSettings(){
  //   SharedPref sharedPref = SharedPref();
  //
  //   // var res = await get(Uri.parse(
  //   //     '${GlobalConfiguration().getValue('api_base_url')}/api/settings/settings.php'));
  //
  //   //Settings settings = (GlobalConfiguration().getValue('settings') as List).map((e) => Settings.fromJson(e));
  //   //List<dynamic> setting = GlobalConfiguration().getValue('settings');
  //   var logoSplashUrl = GlobalConfiguration().getValue('logo_splash_url');
  //   var imgSplashUrl = GlobalConfiguration().getValue('img_splash_url');
  //   var apiBaseUrl = GlobalConfiguration().getValue('api_base_url');
  //   var loader = GlobalConfiguration().getValue('loader');
  //   var loaderColor = GlobalConfiguration().getValue('loaderColor');
  //   var pullRefresh = GlobalConfiguration().getValue('pull_refresh');
  //
  //   sharedPref.save("logo_splash_url", logoSplashUrl);
  //   sharedPref.save("img_splash_url", imgSplashUrl);
  //   sharedPref.save("api_base_url", apiBaseUrl);
  //   sharedPref.save("loader", loader);
  //   sharedPref.save("loaderColor", loaderColor);
  //   sharedPref.save("pull_refresh", pullRefresh);
  //   //print(setting);
  //   // if (res.statusCode == 200) {
  //   //   final json = jsonDecode(res.body);
  //   //   sharedPref.save("settings", json["data"]);
  //   //   Settings settings = Settings.fromJson(json["data"]);
  //   //   return settings;
  //   // } else {
  //   //   throw Exception('Failed to load api');
  //   // }
  // }
}
